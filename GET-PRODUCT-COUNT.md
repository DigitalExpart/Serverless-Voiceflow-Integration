# How to Get Total Product Count in MongoDB

## 🔍 Current Status

**Health Endpoint Shows:** 1 product  
**Search Results Show:** 100+ products found  
**Import Script Mentions:** 70,230 products expected

## 📊 The Discrepancy

The health endpoint count might be incorrect, but **the search proves data exists** (100+ results found).

## ✅ Methods to Get Exact Count

### Method 1: Use the Check Script (Recommended)

1. **Set your MongoDB URI:**
   ```powershell
   $env:MONGO_URI = "mongodb+srv://username:password@cluster.mongodb.net/"
   $env:DB_NAME = "voiceflow_db"
   $env:COLLECTION_NAME = "produits"
   ```

2. **Run the script:**
   ```powershell
   node check-product-count.js
   ```

This will show:
- Total product count
- Products with brand
- Products with designation
- Sample product structure

### Method 2: Check MongoDB Atlas Dashboard

1. Go to: https://cloud.mongodb.com
2. Navigate to your cluster
3. Click on **Collections**
4. Select database: `voiceflow_db`
5. Select collection: `produits`
6. View document count at the top

### Method 3: Use MongoDB Compass

1. Connect to your MongoDB Atlas cluster
2. Navigate to: `voiceflow_db` → `produits`
3. View document count in the collection view

### Method 4: Query via API (After Redeploy)

After redeploying with the fixed count query:

```powershell
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search" -Method Get | Select-Object -ExpandProperty mongodb | Select-Object documentCount
```

## 🔧 Fix Health Check Count

The health check count was fixed in the code. **Redeploy** to see the correct count:

```powershell
vercel --prod
```

After redeploy, the health endpoint will show the actual total count.

## 📝 Expected Values

Based on your import script:
- **Expected:** 70,230 products
- **Actual:** Check using methods above

## 🧪 Quick Test

**Test if data exists:**
```powershell
$body = @{ step = "initial"; query = "test" } | ConvertTo-Json
$response = Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search" -Method Post -Body $body -ContentType "application/json"
Write-Host "Found: $($response.total_count) products"
```

If this shows 100+, your database has products!

## ✅ Summary

- **Database has products** (proven by search results)
- **Exact count:** Use one of the methods above
- **Health check:** Will show correct count after redeploy

