/**
 * MongoDB Data Import Script
 * Imports products-data.json (70,230 products) to MongoDB Atlas
 * 
 * Usage:
 * node import-to-mongodb.js
 */

const { MongoClient } = require('mongodb');
const fs = require('fs');
const path = require('path');

// Configuration
const MONGO_URI = process.env.MONGO_URI || 'YOUR_MONGODB_CONNECTION_STRING';
const DB_NAME = process.env.DB_NAME || 'voiceflow_db';
const COLLECTION_NAME = process.env.COLLECTION_NAME || 'produits';
const DATA_FILE = 'products-data.json';

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  cyan: '\x1b[36m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  blue: '\x1b[34m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function importData() {
  log('\n📊 MongoDB Data Import Tool', 'cyan');
  log('============================', 'cyan');
  
  // Step 1: Check if data file exists
  log('\n📁 Checking data file...', 'yellow');
  if (!fs.existsSync(DATA_FILE)) {
    log(`❌ Error: ${DATA_FILE} not found!`, 'red');
    log('Please make sure products-data.json is in the current directory.', 'yellow');
    process.exit(1);
  }
  
  const fileSize = (fs.statSync(DATA_FILE).size / (1024 * 1024)).toFixed(2);
  log(`✅ Found: ${DATA_FILE} (${fileSize} MB)`, 'green');
  
  // Step 2: Read and parse data
  log('\n📖 Reading JSON data...', 'yellow');
  let products;
  try {
    const rawData = fs.readFileSync(DATA_FILE, 'utf8');
    products = JSON.parse(rawData);
    log(`✅ Parsed ${products.length.toLocaleString()} products`, 'green');
  } catch (error) {
    log(`❌ Error reading file: ${error.message}`, 'red');
    process.exit(1);
  }
  
  // Step 3: Validate MongoDB URI
  if (MONGO_URI === 'YOUR_MONGODB_CONNECTION_STRING') {
    log('\n⚠️  MongoDB connection string not configured!', 'yellow');
    log('\nPlease set your MongoDB URI in one of these ways:', 'cyan');
    log('1. Set environment variable: set MONGO_URI=mongodb+srv://...', 'reset');
    log('2. Or edit this file and replace YOUR_MONGODB_CONNECTION_STRING', 'reset');
    log('\nYour MongoDB Atlas connection string looks like:', 'cyan');
    log('mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/', 'reset');
    process.exit(1);
  }
  
  // Step 4: Connect to MongoDB
  log('\n🔌 Connecting to MongoDB Atlas...', 'yellow');
  log(`   Database: ${DB_NAME}`, 'blue');
  log(`   Collection: ${COLLECTION_NAME}`, 'blue');
  
  let client;
  try {
    client = new MongoClient(MONGO_URI, {
      serverSelectionTimeoutMS: 10000,
    });
    
    await client.connect();
    log('✅ Connected to MongoDB!', 'green');
  } catch (error) {
    log(`❌ Connection failed: ${error.message}`, 'red');
    log('\nTroubleshooting:', 'yellow');
    log('1. Check your MONGO_URI is correct', 'reset');
    log('2. Verify IP whitelist includes 0.0.0.0/0 in MongoDB Atlas', 'reset');
    log('3. Confirm username and password are correct', 'reset');
    process.exit(1);
  }
  
  const db = client.db(DB_NAME);
  const collection = db.collection(COLLECTION_NAME);
  
  // Step 5: Check if collection already has data
  const existingCount = await collection.countDocuments();
  if (existingCount > 0) {
    log(`\n⚠️  Collection already contains ${existingCount.toLocaleString()} documents`, 'yellow');
    log('\nOptions:', 'cyan');
    log('1. Skip import (data already exists)', 'reset');
    log('2. Add new documents (may create duplicates)', 'reset');
    log('3. Replace all data (delete existing and import)', 'reset');
    
    // For automation, we'll skip if data exists
    log('\n✅ Data already imported. Skipping...', 'green');
    await client.close();
    return;
  }
  
  // Step 6: Import data in batches
  log('\n📥 Importing data to MongoDB...', 'yellow');
  log('This may take a few minutes for 70,230 products...', 'cyan');
  
  const batchSize = 1000;
  let imported = 0;
  let errors = 0;
  
  try {
    for (let i = 0; i < products.length; i += batchSize) {
      const batch = products.slice(i, i + batchSize);
      
      try {
        await collection.insertMany(batch, { ordered: false });
        imported += batch.length;
        
        // Show progress
        const progress = ((imported / products.length) * 100).toFixed(1);
        process.stdout.write(`\r   Progress: ${imported.toLocaleString()}/${products.length.toLocaleString()} (${progress}%)`);
      } catch (error) {
        errors++;
        if (error.code !== 11000) { // Ignore duplicate key errors
          log(`\n   Warning: Error in batch ${i / batchSize + 1}: ${error.message}`, 'yellow');
        }
      }
    }
    
    console.log(''); // New line after progress
    
    if (errors > 0) {
      log(`⚠️  Import completed with ${errors} batch warnings`, 'yellow');
    } else {
      log('✅ Import completed successfully!', 'green');
    }
    
  } catch (error) {
    log(`\n❌ Import failed: ${error.message}`, 'red');
    await client.close();
    process.exit(1);
  }
  
  // Step 7: Verify import
  log('\n🔍 Verifying import...', 'yellow');
  const finalCount = await collection.countDocuments();
  log(`✅ Total documents in collection: ${finalCount.toLocaleString()}`, 'green');
  
  // Show sample data
  log('\n📋 Sample documents:', 'cyan');
  const samples = await collection.find().limit(2).toArray();
  samples.forEach((doc, index) => {
    log(`\nDocument ${index + 1}:`, 'blue');
    log(`   Reference: ${doc.Reference}`, 'reset');
    log(`   Designation: ${doc.Designation}`, 'reset');
    log(`   Marque: ${doc.Marque}`, 'reset');
    log(`   Categorie: ${doc['Categorie racine']}`, 'reset');
  });
  
  // Close connection
  await client.close();
  log('\n✅ Connection closed', 'green');
  
  // Next steps
  log('\n============================', 'cyan');
  log('🎉 Import Complete!', 'green');
  log('============================', 'cyan');
  log('\nNext steps:', 'cyan');
  log('1. Create Atlas Search Index (see atlas-search-index-produits.json)', 'reset');
  log('2. Update Vercel environment variables', 'reset');
  log('3. Test your API', 'reset');
  log('\nTo create the search index:', 'yellow');
  log('   • Go to MongoDB Atlas → Database → Search', 'reset');
  log('   • Create new index on "produits" collection', 'reset');
  log('   • Use configuration from atlas-search-index-produits.json', 'reset');
}

// Run the import
importData().catch(error => {
  log(`\n❌ Unexpected error: ${error.message}`, 'red');
  console.error(error);
  process.exit(1);
});

