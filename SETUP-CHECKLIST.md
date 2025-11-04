# Setup Checklist for Voiceflow MongoDB Search API

## ✅ Completed
- [x] Code deployed to GitHub
- [x] Deployed to Vercel: https://serverless-voiceflow-integration.vercel.app
- [x] Health check working
- [x] Input validation working

## 🔄 In Progress - Environment Variables

### Add to Vercel Dashboard

1. Go to: https://vercel.com/the-new-alkebulan/serverless-api/settings/environment-variables

2. Click **"Add New"** and add each variable:

#### Variable 1: MONGO_URI
```
Name: MONGO_URI
Value: mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
Environments: ✓ Production ✓ Preview ✓ Development
```

#### Variable 2: DB_NAME
```
Name: DB_NAME
Value: your_database_name
Environments: ✓ Production ✓ Preview ✓ Development
```

#### Variable 3: COLLECTION_NAME
```
Name: COLLECTION_NAME
Value: products
Environments: ✓ Production ✓ Preview ✓ Development
```

#### Variable 4: SEARCH_INDEX_NAME
```
Name: SEARCH_INDEX_NAME
Value: default
Environments: ✓ Production ✓ Preview ✓ Development
```

3. After adding all variables, **Redeploy**:
   - Go to: Deployments tab
   - Click the ⋯ menu on latest deployment
   - Click "Redeploy"

## 📝 MongoDB Atlas Setup

### 1. Create/Configure MongoDB Atlas Cluster

1. Go to: https://cloud.mongodb.com
2. Create a cluster (if you don't have one)
3. Create a database (e.g., `voiceflow_db`)
4. Create a collection (e.g., `products`)

### 2. Set Network Access

1. In MongoDB Atlas → Security → Network Access
2. Click **"Add IP Address"**
3. Select **"Allow Access from Anywhere"** (`0.0.0.0/0`)
4. Click **Confirm**

> Note: This is required for Vercel serverless functions

### 3. Get Connection String

1. In MongoDB Atlas → Database → Connect
2. Choose **"Connect your application"**
3. Copy the connection string:
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
4. Replace `<username>` and `<password>` with your actual credentials
5. Use this as your `MONGO_URI` in Vercel

### 4. Import Sample Data

Use the `example-data.json` file to populate your collection:

```bash
# Using MongoDB Compass (GUI)
1. Open MongoDB Compass
2. Connect to your cluster
3. Navigate to your database → collection
4. Click "ADD DATA" → "Import JSON or CSV file"
5. Select example-data.json
6. Click Import

# Or using mongoimport (CLI)
mongoimport --uri "mongodb+srv://username:password@cluster.mongodb.net/your_db" \
  --collection products \
  --file example-data.json \
  --jsonArray
```

### 5. Create Atlas Search Index

1. In MongoDB Atlas → Database → Search
2. Click **"Create Search Index"**
3. Choose **"JSON Editor"**
4. Select your database and collection
5. Name it: `default`
6. Paste this configuration (from `atlas-search-index.json`):

```json
{
  "name": "default",
  "mappings": {
    "dynamic": false,
    "fields": {
      "name": {
        "type": "string",
        "analyzer": "lucene.standard"
      },
      "description": {
        "type": "string",
        "analyzer": "lucene.standard"
      },
      "category": {
        "type": "string",
        "analyzer": "lucene.keyword"
      },
      "product_id": {
        "type": "string",
        "analyzer": "lucene.keyword"
      }
    }
  }
}
```

7. Click **"Create Search Index"**
8. Wait 1-2 minutes for the index to become active

## 🧪 Testing

After completing all steps above, run:

```powershell
.\test-deployment.ps1
```

Expected output:
```
✅ Test 1: Health Check - OK
✅ Test 2: Search for 'laptop' - Found products
✅ Test 3: Search for 'phone' - Found products
✅ Test 4: Empty query - Validation working
```

## 🔗 Voiceflow Integration

Once everything is working, integrate with Voiceflow:

### In Voiceflow:
1. Add an **API Block**
2. Configure:
   - **Method**: POST
   - **URL**: `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search`
   - **Headers**: `Content-Type: application/json`
   - **Body**:
     ```json
     {
       "query": "{last_utterance}"
     }
     ```
3. Map the response:
   - Create a variable to store `{response.speech}`
   - Use it in a Text block to speak the results
   - Optionally store `{response.results}` for displaying product details

## 📞 Support

If you encounter issues:
- Check Vercel logs: https://vercel.com/the-new-alkebulan/serverless-api/logs
- Verify MongoDB Atlas IP whitelist includes `0.0.0.0/0`
- Ensure Atlas Search index is active (green status)
- Check environment variables are set correctly

## 🎉 Completion Criteria

- [ ] All environment variables added to Vercel
- [ ] MongoDB Atlas configured with sample data
- [ ] Atlas Search index created and active
- [ ] All 4 tests passing in test-deployment.ps1
- [ ] Voiceflow integration complete

