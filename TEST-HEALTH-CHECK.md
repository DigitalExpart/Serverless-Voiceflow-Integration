# How to Test the Health Check Endpoint

The health check endpoint tests your MongoDB connection and returns the API status.

## 🎯 Your Deployment URL

```
https://serverless-voiceflow-integration.vercel.app
```

## 📋 Method 1: Using PowerShell (Recommended for Windows)

### Quick Test:
```powershell
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search" -Method Get | ConvertTo-Json -Depth 10
```

### Or run the test script:
```powershell
.\test-deployment.ps1
```

## 📋 Method 2: Using Your Web Browser

Simply open this URL in your browser:
```
https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

You'll see a JSON response showing:
- API status
- MongoDB connection status
- Database and collection information

## 📋 Method 3: Using curl (Command Line)

### Windows (PowerShell):
```powershell
curl.exe -X GET "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search"
```

### Windows (Command Prompt):
```cmd
curl -X GET "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search"
```

### Linux/Mac:
```bash
curl -X GET "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search"
```

## 📋 Method 4: Using Postman or Insomnia

1. **Method**: `GET`
2. **URL**: `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search`
3. **Headers**: None required
4. **Body**: None required

Click **Send** and you'll see the response.

## 📋 Method 5: Using Node.js (JavaScript)

```javascript
const response = await fetch('https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search', {
  method: 'GET'
});

const data = await response.json();
console.log(data);
```

## 📋 Method 6: Using Python

```python
import requests

response = requests.get('https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search')
print(response.json())
```

## ✅ Expected Response (When MongoDB is Connected)

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

## ⚠️ Expected Response (When MongoDB is NOT Connected)

```json
{
  "status": "degraded",
  "message": "Voiceflow-MongoDB Search API is running",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "endpoints": {
    "search": "POST /api/voiceflow/search",
    "browse": "POST /api/voiceflow/browse"
  },
  "mongodb": {
    "connected": false,
    "database": "your_database_name",
    "collection": "products",
    "searchIndex": "default",
    "status": "disconnected",
    "error": "Failed to connect to MongoDB: ..."
  }
}
```

## 🔍 What to Check

### ✅ Good Signs:
- `"status": "ok"` 
- `"mongodb.connected": true`
- `"mongodb.status": "connected"`
- `"mongodb.documentCount"` shows a number > 0

### ❌ Problems to Fix:
- `"status": "degraded"` → MongoDB connection failed
- `"mongodb.connected": false` → Check environment variables in Vercel
- `"mongodb.error"` → See error message for details

## 🛠️ Troubleshooting

### If MongoDB is not connected:

1. **Check Vercel Environment Variables:**
   - Go to: https://vercel.com/the-new-alkebulan/serverless-api/settings/environment-variables
   - Verify these are set:
     - `MONGO_URI`
     - `DB_NAME`
     - `COLLECTION_NAME`
     - `SEARCH_INDEX_NAME`

2. **Redeploy after adding variables:**
   - Go to Deployments tab
   - Click ⋯ on latest deployment
   - Click "Redeploy"

3. **Check MongoDB Atlas:**
   - Network Access: Allow `0.0.0.0/0` (all IPs)
   - Database User: Has read/write permissions
   - Connection String: Correct username/password

4. **Check Vercel Logs:**
   - Go to: https://vercel.com/the-new-alkebulan/serverless-api/logs
   - Look for MongoDB connection errors

## 🧪 Test Locally First

Before testing the deployed version, test locally:

```powershell
# Start local server
vercel dev

# In another terminal, test:
Invoke-RestMethod -Uri "http://localhost:3000/api/voiceflow/search" -Method Get
```

Make sure you have a `.env` file with your MongoDB credentials!

