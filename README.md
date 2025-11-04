# Voiceflow MongoDB Atlas Search API

A serverless Node.js/Express function that acts as a webhook middleware between Voiceflow and MongoDB Atlas Search, deployable on Vercel.

## 🚀 Features

- **Serverless Architecture**: Optimized for Vercel deployment with connection pooling
- **MongoDB Atlas Search**: Full-text search with fuzzy matching across multiple fields
- **Voiceflow Integration**: Ready-to-use webhook endpoint with formatted responses
- **Error Handling**: Robust try/catch blocks with friendly error messages
- **Connection Pooling**: Efficient MongoDB client reuse across invocations

## 📋 Prerequisites

1. **MongoDB Atlas Account**
   - Create a cluster at [mongodb.com/atlas](https://www.mongodb.com/atlas)
   - Set up an Atlas Search index on your collection
   
2. **Vercel Account**
   - Sign up at [vercel.com](https://vercel.com)
   
3. **Node.js** (v18 or higher)

## 🛠️ Setup Instructions

### 1. Clone and Install

```bash
npm install
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your MongoDB Atlas credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```env
MONGO_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/
DB_NAME=your_database_name
COLLECTION_NAME=products
SEARCH_INDEX_NAME=default
```

### 3. Create Atlas Search Index

In MongoDB Atlas UI:

1. Navigate to your cluster → "Search" tab
2. Create a new Search Index on your collection
3. Use this basic configuration:

```json
{
  "mappings": {
    "dynamic": true
  }
}
```

Or for specific fields:

```json
{
  "mappings": {
    "fields": {
      "name": {
        "type": "string"
      },
      "description": {
        "type": "string"
      }
    }
  }
}
```

### 4. Deploy to Vercel

```bash
# Install Vercel CLI (if not already installed)
npm install -g vercel

# Deploy
vercel

# Or deploy to production
vercel --prod
```

During deployment, Vercel will ask you to add environment variables. Add all variables from your `.env` file.

Alternatively, set environment variables in the Vercel dashboard:
- Go to your project → Settings → Environment Variables
- Add each variable from `.env`

## 📡 API Endpoint

### POST `/api/voiceflow/search`

**Request Body:**
```json
{
  "query": "laptop"
}
```

**Success Response (200):**
```json
{
  "speech": "I found 3 products: MacBook Pro, Dell XPS, ThinkPad X1.",
  "results": [
    {
      "name": "MacBook Pro",
      "product_id": "prod_001",
      "description": "High-performance laptop",
      "score": 8.5
    },
    {
      "name": "Dell XPS",
      "product_id": "prod_002",
      "description": "Premium ultrabook",
      "score": 7.2
    },
    {
      "name": "ThinkPad X1",
      "product_id": "prod_003",
      "description": "Business laptop",
      "score": 6.8
    }
  ]
}
```

**No Results Response (200):**
```json
{
  "speech": "I couldn't find any products matching \"xyz\". Please try a different search term.",
  "results": []
}
```

**Error Response (500):**
```json
{
  "speech": "I'm sorry, I encountered an error while searching. Please try again later.",
  "results": []
}
```

## 🔗 Voiceflow Integration

1. In your Voiceflow project, add an **API** block
2. Configure the API block:
   - **Method**: POST
   - **URL**: `https://your-deployment.vercel.app/api/voiceflow/search`
   - **Body Type**: JSON
   - **Body Content**:
     ```json
     {
       "query": "{user_input}"
     }
     ```
3. Map the response:
   - Store `response.speech` in a variable for text-to-speech
   - Store `response.results` for displaying product details

## 🧪 Local Testing

```bash
# Install Vercel CLI
npm install -g vercel

# Run locally
vercel dev
```

Then test with curl:

```bash
curl -X POST http://localhost:3000/api/voiceflow/search \
  -H "Content-Type: application/json" \
  -d '{"query": "laptop"}'
```

## 📊 Performance Optimization

- **Connection Pooling**: MongoDB client is cached and reused across function invocations
- **Result Limiting**: Only returns top 5 results to minimize response size
- **Fuzzy Matching**: Handles typos with configurable edit distance
- **Field Projection**: Only returns necessary fields to reduce bandwidth

## 🔒 Security Best Practices

1. Never commit `.env` file to version control
2. Use MongoDB Atlas IP whitelist (or allow all for serverless: `0.0.0.0/0`)
3. Create a dedicated MongoDB user with read-only permissions for the collection
4. Rotate credentials regularly
5. Enable MongoDB Atlas audit logs

## 🐛 Troubleshooting

### "Connection timeout" error
- Check MongoDB Atlas IP whitelist includes `0.0.0.0/0` for Vercel
- Verify `MONGO_URI` is correct

### "Index not found" error
- Ensure Atlas Search index exists and name matches `SEARCH_INDEX_NAME`
- Wait 1-2 minutes after creating index for it to become active

### No results returned
- Verify collection has data
- Check Atlas Search index is active
- Test search query in MongoDB Atlas UI

## 📝 License

MIT

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.


