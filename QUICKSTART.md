# Quick Start Guide

Get your Voiceflow-MongoDB Search API running in 5 minutes!

## Step 1: Install Dependencies

```bash
npm install
```

## Step 2: Configure MongoDB Atlas

### Create Atlas Search Index

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Navigate to your cluster → **Search** tab
3. Click **Create Search Index**
4. Choose **JSON Editor**
5. Paste this configuration:

```json
{
  "mappings": {
    "dynamic": true
  }
}
```

6. Name it `default` (or update `SEARCH_INDEX_NAME` accordingly)
7. Select your database and collection
8. Click **Create**

## Step 3: Set Environment Variables

### For Vercel Deployment:

1. Go to your Vercel project dashboard
2. Navigate to **Settings** → **Environment Variables**
3. Add these variables:

```
MONGO_URI = mongodb+srv://username:password@cluster.mongodb.net/
DB_NAME = your_database_name
COLLECTION_NAME = products
SEARCH_INDEX_NAME = default
```

### For Local Testing:

Create a `.env` file in the root directory:

```bash
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/
DB_NAME=your_database_name
COLLECTION_NAME=products
SEARCH_INDEX_NAME=default
```

## Step 4: Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel
```

Follow the prompts, and your API will be live!

## Step 5: Configure Voiceflow

1. In Voiceflow, add an **API** block
2. Set **Method**: `POST`
3. Set **URL**: `https://your-project.vercel.app/api/voiceflow/search`
4. Set **Body** to:
```json
{
  "query": "{last_utterance}"
}
```
5. Map response → Use `{response.speech}` in a Text block

## Test Your API

### Using curl:

```bash
curl -X POST https://your-project.vercel.app/api/voiceflow/search \
  -H "Content-Type: application/json" \
  -d '{"query": "laptop"}'
```

### Expected Response:

```json
{
  "speech": "I found 3 products: MacBook Pro, Dell XPS, ThinkPad X1.",
  "results": [...]
}
```

## Troubleshooting

**Connection timeout?**
- Add `0.0.0.0/0` to MongoDB Atlas IP whitelist (Network Access)

**No results?**
- Wait 1-2 minutes for Atlas Search index to activate
- Verify collection has data

**500 error?**
- Check environment variables are set correctly
- View logs in Vercel dashboard

---

🎉 **You're all set!** Your Voiceflow bot can now search MongoDB Atlas.

