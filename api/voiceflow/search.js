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
        speech: 'Je n\'ai pas reçu de requête de recherche. Veuillez me dire ce que vous cherchez.',
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
            path: ['Designation', 'Description', 'Marque', 'Categorie racine', 'Sous-categorie 1', 'Sous-categorie 2', 'Reference'],
            fuzzy: {
              maxEdits: 1,
              prefixLength: 2
            }
          }
        }
      },
      {
        $limit: 10
      },
      {
        $project: {
          _id: 0,
          Reference: 1,
          Designation: 1,
          Description: 1,
          Marque: 1,
          'Categorie racine': 1,
          'Sous-categorie 1': 1,
          'Reference du fabricant': 1,
          score: { $meta: 'searchScore' }
        }
      }
    ];

    // Execute search
    const results = await collection.aggregate(searchPipeline).toArray();

    // Format response for Voiceflow
    if (results.length === 0) {
      return res.status(200).json({
        speech: `Je n'ai trouvé aucun produit correspondant à "${query}". Veuillez essayer un autre terme de recherche.`,
        results: []
      });
    }

    // Build speech output
    const productNames = results.map(product => product.Designation || product.Reference || 'Produit sans nom');
    const count = results.length;
    const speech = `J'ai trouvé ${count} produit${count > 1 ? 's' : ''}: ${productNames.slice(0, 5).join(', ')}${count > 5 ? '...' : ''}.`;

    return res.status(200).json({
      speech,
      results: results.map(product => ({
        reference: product.Reference,
        designation: product.Designation,
        description: product.Description,
        marque: product.Marque,
        categorie: product['Categorie racine'],
        sous_categorie: product['Sous-categorie 1'],
        reference_fabricant: product['Reference du fabricant'],
        score: product.score
      }))
    });

  } catch (error) {
    console.error('Error processing search request:', error);

    // Return friendly error message to Voiceflow
    return res.status(500).json({
      speech: 'Désolé, j\'ai rencontré une erreur lors de la recherche. Veuillez réessayer plus tard.',
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


