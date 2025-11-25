# Voiceflow API Connection Test Guide

## ✅ Your API is Ready!

**API Endpoint:**
```
https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

**Status:** ✅ Connected to MongoDB
- Database: `voiceflow_db`
- Collection: `produits`
- Search Index: `default`

---

## 🧪 Step-by-Step: Test in Voiceflow

### Step 1: Create a Simple Test Flow

In your Voiceflow project, create these blocks:

```
[Start]
  ↓
[Text Block: "Bonjour! Que cherchez-vous?"]
  ↓
[Capture Block: user_query]
  ↓
[API Block: Search Products] ← Configure this
  ↓
[Text Block: Display Results]
```

---

### Step 2: Configure the API Block

Click on the **API Block** and configure:

#### **Method:**
```
POST
```

#### **URL:**
```
https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

#### **Headers:**
Click **"+ Add Header"**:
- **Key:** `Content-Type`
- **Value:** `application/json`

#### **Body:**
Select **"Raw Input"** or **"JSON"**, then paste:
```json
{
  "query": "{user_query}"
}
```

#### **Response Mapping:**
Click **"+ Add Mapping"** twice:

**Mapping 1:**
- **Path:** `speech`
- **Variable:** `search_speech` (create new variable)

**Mapping 2:**
- **Path:** `results`
- **Variable:** `search_results` (create new variable)

---

### Step 3: Display Results

Add a **Text Block** after the API block:

**Content:**
```
{search_speech}
```

Or for more details:
```
{search_speech}

Found {search_results.length} products.
```

---

### Step 4: Test in Voiceflow

1. Click the **Test** button (top-right in Voiceflow)
2. Type or say: **"test"** or **"masque"** or **"pipette"**
3. The API should return results from MongoDB!

---

## ✅ What to Expect

### Successful Response:
- **Speech:** "J'ai trouvé X produits: ..."
- **Results:** Array of products with:
  - `reference`
  - `designation`
  - `description`
  - `marque`
  - `categorie`
  - `score`

### If No Results:
- **Speech:** "Je n'ai trouvé aucun produit correspondant à..."
- **Results:** Empty array `[]`

### If Error:
- **Speech:** Error message in French
- **Results:** Empty array `[]`

---

## 🔍 Troubleshooting

### API Block Shows Error?

1. **Check URL:** Make sure it's exactly:
   ```
   https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
   ```

2. **Check Method:** Must be `POST` (not GET)

3. **Check Headers:** Must include `Content-Type: application/json`

4. **Check Body:** Must be valid JSON:
   ```json
   {
     "query": "{user_query}"
   }
   ```

5. **Check Variables:** Make sure `{user_query}` variable exists

### No Results Returned?

- Try different search terms: "test", "masque", "pipette", "CORNING"
- Check MongoDB has data (you have products in the database)
- Verify search index is created in MongoDB Atlas

### Connection Timeout?

- Check Vercel deployment is live
- Check MongoDB Atlas network access allows `0.0.0.0/0`
- Check environment variables in Vercel dashboard

---

## 🧪 Quick Test Queries

Try these in Voiceflow:

1. **"test"** - Should return many results
2. **"masque"** - Search for masks
3. **"pipette"** - Search for pipettes
4. **"CORNING"** - Search by brand
5. **"sécurité"** - Search by category

---

## 📊 Verify Connection Status

You can also test the health check endpoint:

**In Voiceflow API Block:**
- **Method:** `GET`
- **URL:** `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search`
- **No body needed**

This will return MongoDB connection status.

---

## ✅ Success Checklist

- [ ] API Block configured with correct URL
- [ ] Method set to POST
- [ ] Headers include Content-Type
- [ ] Body includes `{user_query}` variable
- [ ] Response mappings configured
- [ ] Test query returns results
- [ ] Speech output displays correctly

---

## 🎯 Next Steps

Once testing works:

1. **Add more blocks** for better user experience
2. **Add error handling** for failed searches
3. **Add product details** display
4. **Add browse functionality** using `/browse` endpoint

Your API is ready and communicating with MongoDB! 🎉

