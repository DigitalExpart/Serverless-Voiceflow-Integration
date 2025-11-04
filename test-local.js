/**
 * Local testing script for the Voiceflow MongoDB Search API
 * 
 * Usage:
 * 1. Make sure your .env file is configured
 * 2. Run: node test-local.js
 * 
 * This script simulates a Voiceflow webhook request
 */

const app = require('./api/voiceflow/search');
const http = require('http');

// Create server
const server = http.createServer(app);
const PORT = process.env.PORT || 3000;

// Sample test queries
const testQueries = [
  { query: 'laptop' },
  { query: 'phone' },
  { query: '' }, // Test empty query
  { query: 'nonexistent12345' } // Test no results
];

async function testEndpoint() {
  console.log('🚀 Starting test server...\n');

  server.listen(PORT, async () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
    console.log(`📡 Endpoint: POST http://localhost:${PORT}/api/voiceflow/search\n`);

    // Run tests
    for (let i = 0; i < testQueries.length; i++) {
      const testData = testQueries[i];
      console.log(`\n--- Test ${i + 1}/${testQueries.length} ---`);
      console.log(`Query: "${testData.query}"`);

      try {
        const response = await fetch(`http://localhost:${PORT}/api/voiceflow/search`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(testData),
        });

        const result = await response.json();
        console.log(`Status: ${response.status}`);
        console.log(`Speech: ${result.speech}`);
        console.log(`Results Count: ${result.results?.length || 0}`);
        
        if (result.results && result.results.length > 0) {
          console.log('Products:', result.results.map(r => r.name).join(', '));
        }
      } catch (error) {
        console.error('❌ Error:', error.message);
      }
    }

    console.log('\n✨ Tests completed!');
    console.log('\nPress Ctrl+C to stop the server');
  });
}

// Handle errors
server.on('error', (error) => {
  console.error('❌ Server error:', error.message);
  process.exit(1);
});

// Run tests
testEndpoint();


