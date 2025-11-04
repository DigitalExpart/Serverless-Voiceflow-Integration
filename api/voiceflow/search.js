const express = require('express');
const { MongoClient } = require('mongodb');

// Initialize Express app
const app = express();
app.use(express.json());

// Environment variables with fallback constants for development
const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://username:password@cluster.mongodb.net/';
const DB_NAME = process.env.DB_NAME || 'your_database_name';
const COLLECTION_NAME = process.env.COLLECTION_NAME || 'products';
const SEARCH_INDEX_NAME = process.env.SEARCH_INDEX_NAME || 'default';

// MongoDB client singleton (connection pooling)
let cachedClient = null;
let cachedDb = null;

/**
 * Connect to MongoDB with connection pooling
 * Reuses existing connection if available
 */
async function connectToDatabase() {
  if (cachedClient && cachedDb) {
    return { client: cachedClient, db: cachedDb };
  }

  const client = new MongoClient(MONGO_URI, {
    maxPoolSize: 10,
    minPoolSize: 2,
    serverSelectionTimeoutMS: 5000,
  });

  await client.connect();
  const db = client.db(DB_NAME);

  cachedClient = client;
  cachedDb = db;

  return { client, db };
}

/**
 * POST /api/voiceflow/search
 * Webhook endpoint for Voiceflow to search MongoDB Atlas
 */
app.post('/api/voiceflow/search', async (req, res) => {
  try {
    // Validate incoming query from Voiceflow
    const { query } = req.body;

    if (!query || typeof query !== 'string' || query.trim() === '') {
      return res.status(200).json({
        speech: 'I didn\'t receive a search query. Please tell me what you\'re looking for.',
        results: []
      });
    }

    // Connect to MongoDB
    const { db } = await connectToDatabase();
    const collection = db.collection(COLLECTION_NAME);

    // MongoDB Atlas Search aggregation pipeline
    const searchPipeline = [
      {
        $search: {
          index: SEARCH_INDEX_NAME,
          text: {
            query: query.trim(),
            path: {
              wildcard: '*' // Search across all fields, or specify: ['name', 'description']
            },
            fuzzy: {
              maxEdits: 1,
              prefixLength: 2
            }
          }
        }
      },
      {
        $limit: 5
      },
      {
        $project: {
          _id: 0,
          name: 1,
          product_id: 1,
          description: 1,
          score: { $meta: 'searchScore' }
        }
      }
    ];

    // Execute search
    const results = await collection.aggregate(searchPipeline).toArray();

    // Format response for Voiceflow
    if (results.length === 0) {
      return res.status(200).json({
        speech: `I couldn't find any products matching "${query}". Please try a different search term.`,
        results: []
      });
    }

    // Build speech output
    const productNames = results.map(product => product.name || 'Unnamed Product');
    const count = results.length;
    const speech = `I found ${count} product${count > 1 ? 's' : ''}: ${productNames.join(', ')}.`;

    return res.status(200).json({
      speech,
      results: results.map(product => ({
        name: product.name,
        product_id: product.product_id,
        description: product.description,
        score: product.score
      }))
    });

  } catch (error) {
    console.error('Error processing search request:', error);

    // Return friendly error message to Voiceflow
    return res.status(500).json({
      speech: 'I\'m sorry, I encountered an error while searching. Please try again later.',
      results: [],
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Health check endpoint (optional but useful)
app.get('/api/voiceflow/search', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Voiceflow-MongoDB Search API is running',
    endpoint: 'POST /api/voiceflow/search'
  });
});

// Export the Express app for Vercel
module.exports = app;


