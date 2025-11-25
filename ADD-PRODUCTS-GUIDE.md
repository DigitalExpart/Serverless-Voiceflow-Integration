# Guide: Adding New Products to MongoDB

## 🎯 Overview

You can now add, update, and delete products via API endpoints. This allows clients to manage products without direct database access.

---

## 📡 API Endpoints

### 1. Add Single Product

**Endpoint:** `POST /api/voiceflow/add-product`

**Request Body:**
```json
{
  "Reference": "NEW001",
  "Designation": "Nouveau produit",
  "Description": "Description du produit",
  "Marque": "BRAND_NAME",
  "Categorie racine": "Catégorie",
  "Sous-categorie 1": "Sous-catégorie",
  "Sous-categorie 2": "Sous-catégorie 2",
  "Sous-categorie 3": "Sous-catégorie 3",
  "Reference du fabricant": "MFG-REF-001"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Product added successfully",
  "product_id": "...",
  "reference": "NEW001",
  "designation": "Nouveau produit"
}
```

**Error Response (409) - Duplicate:**
```json
{
  "success": false,
  "message": "Product with Reference \"NEW001\" already exists",
  "error": "Duplicate Reference"
}
```

---

### 2. Add Multiple Products (Bulk)

**Endpoint:** `POST /api/voiceflow/add-products`

**Request Body:**
```json
{
  "products": [
    {
      "Reference": "NEW001",
      "Designation": "Product 1",
      "Marque": "BRAND1",
      "Categorie racine": "Category 1"
    },
    {
      "Reference": "NEW002",
      "Designation": "Product 2",
      "Marque": "BRAND2",
      "Categorie racine": "Category 2"
    }
  ]
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Successfully added 2 product(s)",
  "inserted_count": 2,
  "total_requested": 2,
  "skipped": 0
}
```

---

### 3. Update Product

**Endpoint:** `PUT /api/voiceflow/update-product`

**Request Body:**
```json
{
  "reference": "NEW001",
  "Designation": "Updated Designation",
  "Description": "Updated description",
  "Marque": "NEW_BRAND"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Product updated successfully",
  "reference": "NEW001",
  "modified_count": 1
}
```

---

### 4. Delete Product

**Endpoint:** `DELETE /api/voiceflow/delete-product`

**Request Body:**
```json
{
  "reference": "NEW001"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Product deleted successfully",
  "reference": "NEW001"
}
```

---

## 🧪 Testing

### Test 1: Add Single Product

**PowerShell:**
```powershell
$product = @{
    Reference = "TEST001"
    Designation = "Test Product"
    Description = "This is a test product"
    Marque = "TEST_BRAND"
    "Categorie racine" = "Test Category"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/add-product" -Method Post -Body $product -ContentType "application/json" | ConvertTo-Json
```

**curl:**
```bash
curl -X POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/add-product \
  -H "Content-Type: application/json" \
  -d '{
    "Reference": "TEST001",
    "Designation": "Test Product",
    "Marque": "TEST_BRAND"
  }'
```

### Test 2: Add Multiple Products

**PowerShell:**
```powershell
$body = @{
    products = @(
        @{ Reference = "TEST001"; Designation = "Product 1"; Marque = "BRAND1" },
        @{ Reference = "TEST002"; Designation = "Product 2"; Marque = "BRAND2" }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/add-products" -Method Post -Body $body -ContentType "application/json" | ConvertTo-Json
```

---

## 📋 Required Fields

### Minimum Required:
- `Reference` (unique identifier)
- `Designation` (product name)

### Optional Fields:
- `Description`
- `Marque` (brand)
- `Categorie racine`
- `Sous-categorie 1`, `Sous-categorie 2`, `Sous-categorie 3`
- `Reference du fabricant`

---

## 🔒 Security Considerations

**Current Implementation:**
- No authentication required (for development)
- Anyone with the endpoint URL can add products

**For Production, Add:**
1. **API Key Authentication**
2. **Rate Limiting**
3. **Input Validation**
4. **Admin-only access**

---

## 🛠️ Adding Authentication (Optional)

To secure the endpoints, add authentication middleware:

```javascript
// Add API key check
const API_KEY = process.env.ADMIN_API_KEY;

function requireApiKey(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || apiKey !== API_KEY) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized - Invalid API key'
    });
  }
  next();
}

// Apply to add/update/delete endpoints
app.post('/api/voiceflow/add-product', requireApiKey, async (req, res) => {
  // ... existing code
});
```

Then set `ADMIN_API_KEY` in Vercel environment variables.

---

## 📊 Product Structure

**Example Product:**
```json
{
  "Reference": "508231",
  "Designation": "Tubes à sceller par capsule aluminium",
  "Description": "Tube étanche aux gaz...",
  "Marque": "BELLCO",
  "Categorie racine": "Consommable",
  "Sous-categorie 1": "tube",
  "Sous-categorie 2": null,
  "Sous-categorie 3": null,
  "Reference du fabricant": "0572 1641 01"
}
```

---

## ✅ Best Practices

1. **Use unique References** - Reference is used as identifier
2. **Validate before adding** - Check required fields
3. **Handle duplicates** - API will reject duplicate References
4. **Bulk insert for many products** - Use `/add-products` for efficiency
5. **Update instead of delete+add** - Use `/update-product` to modify

---

## 🔄 Workflow Example

1. **Add new product:**
   ```json
   POST /api/voiceflow/add-product
   { "Reference": "NEW001", "Designation": "New Product", ... }
   ```

2. **Update product:**
   ```json
   PUT /api/voiceflow/update-product
   { "reference": "NEW001", "Description": "Updated description" }
   ```

3. **Search for product:**
   ```json
   POST /api/voiceflow/smart-search
   { "step": "initial", "query": "New Product" }
   ```

4. **Delete if needed:**
   ```json
   DELETE /api/voiceflow/delete-product
   { "reference": "NEW001" }
   ```

---

## 🚀 Deployment

After adding these endpoints, deploy:

```powershell
vercel --prod
```

The endpoints will be available at:
- `POST https://your-deployment.vercel.app/api/voiceflow/add-product`
- `POST https://your-deployment.vercel.app/api/voiceflow/add-products`
- `PUT https://your-deployment.vercel.app/api/voiceflow/update-product`
- `DELETE https://your-deployment.vercel.app/api/voiceflow/delete-product`

---

## 📝 Notes

- Products are immediately searchable after adding
- No need to rebuild search index (Atlas Search updates automatically)
- Reference must be unique (duplicates will be rejected)
- Bulk insert skips duplicates automatically

