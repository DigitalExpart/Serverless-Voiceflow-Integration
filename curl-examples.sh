#!/bin/bash

# Curl Examples for Testing the Voiceflow MongoDB Search API
# Replace YOUR_DEPLOYMENT_URL with your actual Vercel deployment URL

BASE_URL="https://your-project.vercel.app"
# For local testing, use: BASE_URL="http://localhost:3000"

echo "🧪 Testing Voiceflow MongoDB Search API"
echo "========================================="
echo ""

# Test 1: Basic search query
echo "Test 1: Search for 'laptop'"
curl -X POST "$BASE_URL/api/voiceflow/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "laptop"}'
echo -e "\n\n"

# Test 2: Search with different term
echo "Test 2: Search for 'phone'"
curl -X POST "$BASE_URL/api/voiceflow/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "phone"}'
echo -e "\n\n"

# Test 3: Empty query
echo "Test 3: Empty query"
curl -X POST "$BASE_URL/api/voiceflow/search" \
  -H "Content-Type: application/json" \
  -d '{"query": ""}'
echo -e "\n\n"

# Test 4: Query with no results
echo "Test 4: Query with no results"
curl -X POST "$BASE_URL/api/voiceflow/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "nonexistentproduct12345"}'
echo -e "\n\n"

# Test 5: Search by category
echo "Test 5: Search for 'audio'"
curl -X POST "$BASE_URL/api/voiceflow/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "audio"}'
echo -e "\n\n"

# Test 6: Fuzzy search (typo)
echo "Test 6: Fuzzy search - 'laptp' (typo for laptop)"
curl -X POST "$BASE_URL/api/voiceflow/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "laptp"}'
echo -e "\n\n"

# Test 7: Health check (GET request)
echo "Test 7: Health check"
curl -X GET "$BASE_URL/api/voiceflow/search"
echo -e "\n\n"

echo "✅ All tests completed!"

