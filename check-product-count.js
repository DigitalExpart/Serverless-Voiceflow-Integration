/**
 * Check total product count in MongoDB
 * Usage: node check-product-count.js
 */

const { MongoClient } = require('mongodb');

// Get from environment or use defaults
const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://username:password@cluster.mongodb.net/';
const DB_NAME = process.env.DB_NAME || 'voiceflow_db';
const COLLECTION_NAME = process.env.COLLECTION_NAME || 'produits';

async function checkCount() {
  console.log('\n🔍 Checking MongoDB Product Count...\n');
  console.log(`Database: ${DB_NAME}`);
  console.log(`Collection: ${COLLECTION_NAME}\n`);

  if (!MONGO_URI || MONGO_URI.includes('username:password')) {
    console.error('❌ MONGO_URI not configured. Set it in environment variables.');
    process.exit(1);
  }

  let client;
  try {
    client = new MongoClient(MONGO_URI, {
      serverSelectionTimeoutMS: 10000,
    });
    
    await client.connect();
    console.log('✅ Connected to MongoDB\n');
    
    const db = client.db(DB_NAME);
    const collection = db.collection(COLLECTION_NAME);
    
    // Count total documents
    console.log('⏳ Counting documents (this may take a moment for large collections)...\n');
    const totalCount = await collection.countDocuments({});
    console.log(`📊 TOTAL PRODUCTS: ${totalCount.toLocaleString()}`);
    
    if (totalCount === 0) {
      console.log('\n⚠️  WARNING: Collection is empty!');
      console.log('   You may need to run the import script:');
      console.log('   node import-to-mongodb.js\n');
    } else if (totalCount < 1000) {
      console.log('\n⚠️  WARNING: Very few products found!');
      console.log('   Expected: ~70,230 products');
      console.log('   Actual: ' + totalCount.toLocaleString());
      console.log('   You may need to run the import script:\n');
      console.log('   node import-to-mongodb.js\n');
    } else if (totalCount >= 70000) {
      console.log('\n✅ Excellent! Database has the expected number of products!');
    }
    
    // Count by some fields to verify data
    const withBrand = await collection.countDocuments({ Marque: { $exists: true, $ne: null } });
    const withDesignation = await collection.countDocuments({ Designation: { $exists: true, $ne: null } });
    const withReference = await collection.countDocuments({ Reference: { $exists: true, $ne: null } });
    
    console.log(`\n📈 Data Quality Breakdown:`);
    console.log(`   Products with Brand: ${withBrand.toLocaleString()} (${((withBrand/totalCount)*100).toFixed(1)}%)`);
    console.log(`   Products with Designation: ${withDesignation.toLocaleString()} (${((withDesignation/totalCount)*100).toFixed(1)}%)`);
    console.log(`   Products with Reference: ${withReference.toLocaleString()} (${((withReference/totalCount)*100).toFixed(1)}%)`);
    
    // Sample a few products to verify structure
    const sample = await collection.find({}).limit(3).toArray();
    if (sample.length > 0) {
      console.log(`\n📋 Sample Product Structure:`);
      console.log(`   Fields: ${Object.keys(sample[0]).join(', ')}`);
      console.log(`\n   Example Product:`);
      console.log(`   - Reference: ${sample[0].Reference || 'N/A'}`);
      console.log(`   - Designation: ${(sample[0].Designation || 'N/A').substring(0, 50)}...`);
      console.log(`   - Marque: ${sample[0].Marque || 'N/A'}`);
    }
    
    // Check for other collections in the database
    const collections = await db.listCollections().toArray();
    console.log(`\n📚 Collections in database "${DB_NAME}":`);
    collections.forEach(col => {
      console.log(`   - ${col.name}`);
    });
    
    await client.close();
    console.log('\n✅ Check complete!\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (client) {
      await client.close();
    }
    process.exit(1);
  }
}

checkCount();

