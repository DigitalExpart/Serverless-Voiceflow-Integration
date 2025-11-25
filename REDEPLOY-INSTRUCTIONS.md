# How to Redeploy to Vercel

Your health check endpoint is working, but it needs to be redeployed to show MongoDB connection status.

## 🚀 Quick Redeploy

### Option 1: Using Vercel CLI (Recommended)

```powershell
# Make sure you're in the project directory
cd "C:\Users\user\API for vo"

# Deploy to production
vercel --prod
```

### Option 2: Using Vercel Dashboard

1. Go to: https://vercel.com/the-new-alkebulan/serverless-api
2. Click on the **Deployments** tab
3. Find the latest deployment
4. Click the **⋯** (three dots) menu
5. Click **Redeploy**
6. Wait for deployment to complete (usually 1-2 minutes)

## ✅ After Redeploying

Test again in your browser:
```
https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

You should now see a response like:

```json
{
  "status": "ok",
  "message": "Voiceflow-MongoDB Search API is running",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "endpoints": {
    "search": "POST /api/voiceflow/search",
    "browse": "POST /api/voiceflow/browse"
  },
  "mongodb": {
    "connected": true,
    "database": "your_database_name",
    "collection": "products",
    "searchIndex": "default",
    "documentCount": 70230,
    "status": "connected"
  }
}
```

## ⚠️ If MongoDB Shows as Disconnected

If after redeploying you see `"mongodb.connected": false`, check:

1. **Environment Variables in Vercel:**
   - Go to: Settings → Environment Variables
   - Verify these are set:
     - `MONGO_URI`
     - `DB_NAME`
     - `COLLECTION_NAME`
     - `SEARCH_INDEX_NAME`

2. **Redeploy again** after adding/updating environment variables

3. **Check MongoDB Atlas:**
   - Network Access: Allow `0.0.0.0/0`
   - Database User: Has correct permissions

