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
    const { query, limit } = req.body;

    if (!query || typeof query !== 'string' || query.trim() === '') {
      return res.status(200).json({
        speech: 'Je n\'ai pas reçu de requête de recherche. Veuillez me dire ce que vous cherchez.',
        results: []
      });
    }

    // Set result limit (default 100, max 500)
    const resultLimit = Math.min(parseInt(limit) || 100, 500);

    // Prepare query variations to better support French accents/diacritics
    const trimmedQuery = query.trim();
    const lowerCaseQuery = trimmedQuery.toLowerCase();
    const normalizedQuery = trimmedQuery
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');

    const searchPaths = [
      'Designation',
      'Description',
      'Marque',
      'Categorie racine',
      'Sous-categorie 1',
      'Sous-categorie 2',
      'Reference'
    ];

    const buildTextStage = (queryString, boost) => {
      const textStage = {
        path: searchPaths,
        query: queryString
      };

      if (queryString.length >= 3) {
        textStage.fuzzy = {
          maxEdits: 1,
          prefixLength: 2
        };
      }

      if (boost && boost > 1) {
        textStage.score = { boost: { value: boost } };
      }

      return { text: textStage };
    };

    const phraseTranslations = [
      { pattern: /\bglass\s+tubes?\b/gi, replacement: 'tubes en verre' },
      { pattern: /\bglass\s+tube\b/gi, replacement: 'tube en verre' },
      { pattern: /\bborosilicate\b/gi, replacement: 'borosilicate' },
      { pattern: /\bpyrex\b/gi, replacement: 'pyrex' },
      { pattern: /\bsecurity\s+cameras?\b/gi, replacement: 'caméra de sécurité' },
      { pattern: /\bsurveillance\s+cameras?\b/gi, replacement: 'caméra de surveillance' },
      { pattern: /\bsurveillance\b/gi, replacement: 'surveillance' },
      { pattern: /\bsafety\s+equipment\b/gi, replacement: 'équipement de sécurité' },
      { pattern: /\bsmart\s+lock\b/gi, replacement: 'serrure connectée' },
      { pattern: /\bfire\s+alarm\b/gi, replacement: 'alarme incendie' },
      { pattern: /\bprotective\s+mask\b/gi, replacement: 'masque de protection' },
      { pattern: /\bprotective\s+gloves?\b/gi, replacement: 'gants de protection' }
    ];

    let phraseTranslatedQuery = trimmedQuery;
    for (const { pattern, replacement } of phraseTranslations) {
      phraseTranslatedQuery = phraseTranslatedQuery.replace(pattern, replacement);
    }

    const translationDictionary = {
      security: 'sécurité',
      secure: 'sécurisé',
      safety: 'sécurité',
      protection: 'protection',
      surveillance: 'surveillance',
      camera: 'caméra',
      cameras: 'caméras',
      alarm: 'alarme',
      alarms: 'alarmes',
      lock: 'serrure',
      locks: 'serrures',
      glass: 'verre',
      tube: 'tube',
      tubes: 'tubes',
      mask: 'masque',
      masks: 'masques',
      cleaning: 'nettoyage',
      disinfectant: 'désinfectant',
      disinfectants: 'désinfectants'
    };

    const translatedTokens = phraseTranslatedQuery
      .split(/\s+/)
      .map(token => {
        const lower = token.toLowerCase();
        return translationDictionary[lower] || token;
      });

    const translatedQuery = translatedTokens.join(' ');

    const keywordExpansions = {
      glass: ['verre'],
      tube: ['tube', 'verre'],
      tubes: ['tubes', 'tube', 'verre'],
      borosilicate: ['borosilicate'],
      pyrex: ['pyrex'],
      security: ['sécurité'],
      camera: ['caméra', 'sécurité'],
      cameras: ['caméras', 'sécurité'],
      alarm: ['alarme', 'sécurité'],
      alarms: ['alarmes', 'sécurité'],
      lock: ['serrure'],
      locks: ['serrures'],
      cleaning: ['nettoyage', 'désinfection'],
      disinfectant: ['désinfectant'],
      surveillance: ['surveillance'],
      respirator: ['respiratoire'],
      mask: ['masque'],
      masks: ['masques'],
      glove: ['gant'],
      gloves: ['gants'],
      safety: ['sécurité']
    };

    const expansionTokens = new Set();
    for (const [englishWord, synonyms] of Object.entries(keywordExpansions)) {
      const wordPattern = new RegExp(`\\b${englishWord}\\b`, 'i');
      if (wordPattern.test(lowerCaseQuery)) {
        synonyms.forEach(token => expansionTokens.add(token));
      }
    }

    const queryVariants = new Map();
    queryVariants.set(trimmedQuery, 3);

    if (normalizedQuery !== trimmedQuery) {
      queryVariants.set(normalizedQuery, 2);
    }

    if (translatedQuery !== trimmedQuery) {
      queryVariants.set(translatedQuery, 2);
      const normalizedTranslatedQuery = translatedQuery
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');
      if (normalizedTranslatedQuery !== translatedQuery) {
        queryVariants.set(normalizedTranslatedQuery, 1.5);
      }
    }

    if (expansionTokens.size > 0) {
      const appendedKeywords = Array.from(expansionTokens).join(' ');
      const expandedQuery = `${translatedQuery} ${appendedKeywords}`.trim();
      if (!queryVariants.has(expandedQuery)) {
        queryVariants.set(expandedQuery, 1.5);
      }

      const expandedNormalizedQuery = expandedQuery
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');

      if (!queryVariants.has(expandedNormalizedQuery)) {
        queryVariants.set(expandedNormalizedQuery, 1.25);
      }
    }

    // Connect to MongoDB
    const { db } = await connectToDatabase();
    const collection = db.collection(COLLECTION_NAME);

    // MongoDB Atlas Search aggregation pipeline
    const searchPipeline = [
      {
        $search: {
          index: SEARCH_INDEX_NAME,
          compound: {
            should: Array.from(queryVariants.entries()).map(([variant, boost]) =>
              buildTextStage(variant, boost)
            ),
            minimumShouldMatch: 1
          }
        }
      },
      {
        $limit: resultLimit
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
    const count = results.length;
    let speech;
    
    if (count <= 10) {
      // For 10 or fewer results, list them
      const productNames = results.map(product => product.Designation || product.Reference || 'Produit sans nom');
      speech = `J'ai trouvé ${count} produit${count > 1 ? 's' : ''}: ${productNames.slice(0, 5).join(', ')}${count > 5 ? '...' : ''}.`;
    } else {
      // For more than 10 results, just give the count
      speech = `J'ai trouvé ${count} produit${count > 1 ? 's' : ''} correspondant à votre recherche. Vous pouvez affiner votre recherche ou parcourir les résultats.`;
    }

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
    console.error('Error processing search request:', {
      message: error.message,
      stack: error.stack
    });

    // Return friendly error message to Voiceflow
    return res.status(500).json({
      speech: `Désolé, j'ai rencontré une erreur lors de la recherche${error?.message ? ` : ${error.message}` : ''}. Veuillez réessayer plus tard.`,
      results: [],
      error: error?.message
    });
  }
});

/**
 * POST /api/voiceflow/browse
 * Get all products with category and brand recommendations
 */
app.post('/api/voiceflow/browse', async (req, res) => {
  try {
    const { category, brand, limit } = req.body;
    
    // Connect to MongoDB
    const { db } = await connectToDatabase();
    const collection = db.collection(COLLECTION_NAME);

    // Build match criteria
    const matchCriteria = {};
    if (category) {
      matchCriteria['Categorie racine'] = category;
    }
    if (brand) {
      matchCriteria['Marque'] = brand;
    }

    // Get products with optional filtering
    const resultLimit = Math.min(parseInt(limit) || 500, 1000);
    
    const pipeline = [
      ...(Object.keys(matchCriteria).length > 0 ? [{ $match: matchCriteria }] : []),
      { $limit: resultLimit },
      {
        $project: {
          _id: 0,
          Reference: 1,
          Designation: 1,
          Description: 1,
          Marque: 1,
          'Categorie racine': 1,
          'Sous-categorie 1': 1,
          'Sous-categorie 2': 1,
          'Reference du fabricant': 1
        }
      }
    ];

    const allProducts = await collection.aggregate(pipeline).toArray();

    // Get category statistics
    const categoryStats = await collection.aggregate([
      { $group: { 
          _id: '$Categorie racine', 
          count: { $sum: 1 } 
        } 
      },
      { $sort: { count: -1 } },
      { $limit: 10 }
    ]).toArray();

    // Get brand statistics
    const brandStats = await collection.aggregate([
      { $group: { 
          _id: '$Marque', 
          count: { $sum: 1 } 
        } 
      },
      { $sort: { count: -1 } },
      { $limit: 20 }
    ]).toArray();

    // Get top 5 recommended products (random sample from results)
    const topProducts = allProducts
      .sort(() => 0.5 - Math.random())
      .slice(0, 5);

    // Build speech
    const totalCount = allProducts.length;
    let speech = '';
    
    if (category && brand) {
      speech = `J'ai trouvé ${totalCount} produits ${brand} dans la catégorie ${category}. Voici mes 5 recommandations.`;
    } else if (category) {
      speech = `J'ai trouvé ${totalCount} produits dans la catégorie ${category}. Voici mes 5 meilleures recommandations.`;
    } else if (brand) {
      speech = `J'ai trouvé ${totalCount} produits de la marque ${brand}. Voici mes 5 meilleures recommandations.`;
    } else {
      speech = `Catalogue complet: ${totalCount} produits disponibles. Voici 5 produits recommandés parmi ${categoryStats.length} catégories et ${brandStats.length} marques.`;
    }

    return res.status(200).json({
      speech,
      total_products: totalCount,
      categories: categoryStats.map(c => ({ name: c._id, count: c.count })),
      brands: brandStats.map(b => ({ name: b._id, count: b.count })),
      top_5_recommendations: topProducts.map(product => ({
        reference: product.Reference,
        designation: product.Designation,
        description: product.Description,
        marque: product.Marque,
        categorie: product['Categorie racine'],
        sous_categorie: product['Sous-categorie 1']
      })),
      all_products: allProducts.map(product => ({
        reference: product.Reference,
        designation: product.Designation,
        description: product.Description,
        marque: product.Marque,
        categorie: product['Categorie racine'],
        sous_categorie: product['Sous-categorie 1']
      }))
    });

  } catch (error) {
    console.error('Error processing browse request:', error);
    return res.status(500).json({
      speech: 'Désolé, j\'ai rencontré une erreur. Veuillez réessayer plus tard.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Health check endpoint (optional but useful)
app.get('/api/voiceflow/search', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Voiceflow-MongoDB Search API is running',
    endpoints: {
      search: 'POST /api/voiceflow/search',
      browse: 'POST /api/voiceflow/browse'
    }
  });
});

// Export the Express app for Vercel
module.exports = app;


