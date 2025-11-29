# Voiceflow Integration Guide - AI Agent Setup
## Complete Setup for MongoDB Product Search with AI Processing

### 🎯 Your API Endpoint
```
https://serverlessvoiceflow.vercel.app/api/voiceflow/search
```

### ⚡ Key Update: Full Database Access
Your API now returns **ALL fields** from the database (prices, volumes, sizes, shapes, quality, descriptions, etc.) - perfect for AI-powered conversations!

---

## 🤖 AI Agent Configuration (Recommended)

### **Option 1: Use Voiceflow AI Agent (Best for Natural Conversations)**

This is the **recommended approach** - let the AI handle search results naturally:

#### Step 1: Create an API Tool/Function

1. **Go to**: Agent Settings → Tools → Add API
2. **Name**: `search_products`
3. **Description**: 
   ```
   Search for products in the catalog. Returns complete product information including 
   prices, volumes, sizes, brands, descriptions, and all specifications.
   ```

4. **Method**: `POST`
5. **URL**: `https://serverlessvoiceflow.vercel.app/api/voiceflow/search`

6. **Headers**:
   ```
   Content-Type: application/json
   ```

7. **Request Body**:
   ```json
   {
     "query": "{{query}}"
   }
   ```

8. **Parameters**:
   - **Name**: `query`
   - **Type**: `string`
   - **Required**: `true`
   - **Description**: `The user's search query for products`

9. **Response Path**: Leave as root or map to `results`

#### Step 2: Configure AI Agent Instructions

Add these instructions to your AI Agent (in Agent Settings → Instructions):

```
You are a helpful product search assistant for a laboratory supplies catalog.

CAPABILITIES:
- You can search for products using the search_products function
- You have access to complete product information including:
  * Reference numbers
  * Product names and descriptions
  * Brands (Marque)
  * Prices (Prix)
  * Volumes (Volume) like 2ml, 5ml, etc.
  * Sizes (Taille)
  * Shapes (Forme)
  * Quality grades (Qualité)
  * Materials (Matériau)
  * Categories and subcategories
  * Stock availability
  * All other product specifications

BEHAVIOR:
- When a user asks about products, use the search_products function
- Present ALL relevant results from the API response
- Include key details like prices, sizes, brands in your responses
- If asked for specific details (price, volume, etc.), extract them from the results
- Be conversational and helpful
- Answer follow-up questions using the search results
- If no results are found, suggest alternative search terms

RESPONSE FORMAT:
- Summarize the number of products found
- List products with their key attributes (name, brand, price, volume)
- Offer to provide more details about specific products
- Keep responses natural and conversational
```

#### Step 3: Test Your AI Agent

Try these queries:
- "Find me tubes en verre"
- "What's the price of 2ml glass tubes?"
- "Show me CORNING products"
- "I need laboratory masks, what do you have?"

---

## 🔧 Option 2: Traditional Flow (Manual Configuration)

If you prefer traditional Voiceflow flows instead of AI:

### Flow Structure:

```
[Start] 
  ↓
[Text Block: "Bienvenue! Que cherchez-vous?"]
  ↓
[Capture Response] → Store in variable: {user_query}
  ↓
[API Block: Search Products]
  ↓
[Code Block: Process Results]
  ↓
[Condition: Check if results found]
  ├─ Yes → [Text Block: Show Results]
  └─ No → [Text Block: "Aucun produit trouvé"]
```

### 1. Text Block (Welcome Message)
```
Bonjour! Je peux vous aider à trouver des produits.
Que recherchez-vous?
```

### 2. Capture Block
- **Variable Name**: `user_query`
- **Type**: Text
- **Wait for user response**

### 3. API Block Configuration

**Request Setup:**
- **Method**: `POST`
- **URL**: `https://serverlessvoiceflow.vercel.app/api/voiceflow/search`

**Headers:**
```
Content-Type: application/json
```

**Body (Raw JSON):**
```json
{
  "query": "{user_query}"
}
```

**Response Mapping:**

Map the ENTIRE response to variables:

| Response Path | Variable Name | Description |
|---------------|---------------|-------------|
| `success` | `api_success` | API call status |
| `count` | `product_count` | Total products found |
| `message` | `api_message` | Summary message |
| `results` | `products` | Complete array of ALL products |

### 4. Code Block (Process Results)

Use a code block to extract information from the full results:

```javascript
// Get first product details
const firstProduct = products[0] || {};

// Store in variables
vars.product_name = firstProduct.Designation || 'N/A';
vars.product_ref = firstProduct.Reference || 'N/A';
vars.product_brand = firstProduct.Marque || 'N/A';
vars.product_price = firstProduct.Prix || 'N/A';
vars.product_volume = firstProduct.Volume || 'N/A';
vars.product_size = firstProduct.Taille || 'N/A';
vars.product_description = firstProduct.Description || 'N/A';

// Create summary of first 3 products
let summary = '';
for (let i = 0; i < Math.min(3, products.length); i++) {
  const p = products[i];
  summary += `${i+1}. ${p.Designation} - ${p.Marque}`;
  if (p.Prix) summary += ` - ${p.Prix}€`;
  if (p.Volume) summary += ` (${p.Volume})`;
  summary += '\n';
}
vars.products_summary = summary;
```

### 5. Condition Block (Check Results)

**Condition:**
```
{product_count} > 0
```

**If TRUE**: Show results
**If FALSE**: Show no results message

### 6. Text Block (Show Results)

```
J'ai trouvé {product_count} produit(s) pour "{user_query}":

{products_summary}

Voulez-vous plus de détails sur un produit spécifique?
```

---

## 🔐 Updated API Response Structure

Your API now returns **COMPLETE product data** from MongoDB:

```json
{
  "success": true,
  "count": 25,
  "message": "25 produits trouvés",
  "query": "tubes verre",
  "results": [
    {
      "Reference": "REF001",
      "Designation": "Tube à essai en verre borosilicate",
      "Description": "Tube haute qualité pour laboratoire...",
      "Marque": "CORNING",
      "Categorie racine": "Laboratoire",
      "Sous-categorie 1": "Verrerie",
      "Sous-categorie 2": "Tubes",
      "Sous-categorie 3": "Essai",
      "Reference du fabricant": "COR-TB-001",
      "Prix": "2.50",
      "Volume": "2ml",
      "Taille": "12 x 75mm",
      "Forme": "Cylindrique",
      "Qualité": "Grade A",
      "Matériau": "Verre borosilicate",
      "Quantité": "100",
      "Poids": "15g",
      "Couleur": "Transparent",
      "Code-barres": "1234567890123",
      "Stock": "En stock",
      "Image": "https://...",
      "score": 15.2
      // ... ALL other fields from your database
    }
    // ... all matching products
  ],
  "metadata": {
    "search_performed": true,
    "timestamp": "2025-11-29T...",
    "total_results": 25
  }
}
```

### 📊 Available Fields (ALL fields from your database):

**Basic Information:**
- `Reference` - Product reference number
- `Designation` - Product name
- `Description` - Full product description
- `Marque` - Brand name
- `Reference du fabricant` - Manufacturer reference

**Categories:**
- `Categorie racine` - Root category
- `Sous-categorie 1` - First subcategory
- `Sous-categorie 2` - Second subcategory  
- `Sous-categorie 3` - Third subcategory

**Specifications:**
- `Prix` - Price
- `Volume` - Volume (e.g., 2ml, 5ml, 100ml)
- `Taille` - Size/Dimensions
- `Forme` - Shape
- `Qualité` - Quality grade
- `Matériau` - Material
- `Poids` - Weight
- `Couleur` - Color
- `Dimensions` - Measurements

**Inventory:**
- `Quantité` - Quantity
- `Stock` - Stock status
- `Code-barres` - Barcode
- `Image` - Product image URL

**Search:**
- `score` - Search relevance score (higher = better match)

**Plus ALL other fields** that exist in your MongoDB collection!

---

## 🤖 AI Agent Example Conversations

**User:** "Show me 2ml glass tubes"

**AI Agent:**
```
I found 15 products matching "2ml glass tubes":

1. Tube à essai en verre borosilicate - 2ml
   Brand: CORNING
   Price: 2.50€
   Size: 12 x 75mm
   Material: Borosilicate glass
   In stock

2. Tube verre gradué - 2ml
   Brand: PYREX
   Price: 3.20€
   Size: 13 x 100mm
   Material: Pyrex glass
   In stock

[... more products ...]

Would you like more details about any specific product?
```

**User:** "What's the cheapest one?"

**AI Agent:**
```
The most affordable option is the CORNING Tube à essai en verre 
borosilicate at 2.50€ for a 2ml tube (12 x 75mm).

Would you like to know more about this product or see other options?
```

---

## 💡 Pro Tips for AI Agent Setup

### 1. **Context Management**
Store search results in the conversation context so the AI can answer follow-up questions like:
- "What about the prices?"
- "Show me only CORNING products"
- "Which one is the biggest?"

### 2. **Multi-turn Conversations**
The AI can naturally handle:
- Filtering results by brand, price range, volume
- Comparing products
- Answering specific questions about attributes
- Making recommendations

### 3. **Custom Instructions Examples**

**For Price-Focused Agent:**
```
Always mention prices prominently. When showing products, list them 
from cheapest to most expensive unless user specifies otherwise.
```

**For Specification-Focused Agent:**
```
Emphasize technical specifications like volume, material, size. 
Provide detailed specs when users ask about product capabilities.
```

**For Brand-Focused Agent:**
```
Group products by brand when showing results. Highlight premium 
brands like CORNING, PYREX, MERCK.
```

### 4. **Error Handling in AI Instructions**

Add to your AI instructions:
```
If the search returns no results:
- Suggest alternative search terms
- Ask if they want to browse by category
- Offer to search for similar products

If the API fails:
- Apologize for technical issues
- Ask user to try again
- Offer alternative ways to help
```

---

## 🧪 Testing Scenarios

Test your AI agent with these scenarios:

### Basic Search:
- "Find tubes"
- "Show me laboratory equipment"
- "Do you have masks?"

### Specification Search:
- "I need 5ml tubes"
- "Show me products under 10 euros"
- "What glass tubes do you have?"

### Brand Search:
- "CORNING products"
- "Show me PYREX items"
- "What brands do you carry?"

### Follow-up Questions:
- After search: "What are the prices?"
- After search: "Which one is the biggest?"
- After search: "Show me only the glass ones"

### Comparison:
- "Compare the first two products"
- "What's the difference between CORNING and PYREX tubes?"

---

## 🎬 Quick Start: AI Agent (5 Minutes)

1. **Create API Tool:**
   - Name: `search_products`
   - URL: `https://serverlessvoiceflow.vercel.app/api/voiceflow/search`
   - Method: POST
   - Body: `{"query": "{{query}}"}`

2. **Add AI Instructions:**
   ```
   You search laboratory products. Use search_products function 
   when users ask about products. Present results with key details 
   like name, brand, price, volume, size. Answer follow-up questions 
   naturally.
   ```

3. **Test:**
   - "Find 2ml tubes"
   - "What's the price?"
   - "Show me CORNING products"

4. **Done!** Your AI agent can now search and discuss products naturally.

---

## 🎬 Quick Start: Traditional Flow (10 Minutes)

1. **Start** → **Text**: "Que cherchez-vous?"
2. **Capture**: variable `user_query`
3. **API Call**: 
   - POST `https://serverlessvoiceflow.vercel.app/api/voiceflow/search`
   - Body: `{"query": "{user_query}"}`
   - Map `results` → `products`
   - Map `count` → `product_count`
4. **Code**: Process `products` array
5. **Text**: Display results
6. **Choice**: "Chercher autre chose?" → Loop back

---

## 📞 Support & Troubleshooting

### Common Issues:

**1. API returns no results:**
- Check if query is empty
- Try simpler search terms
- Verify API URL is correct

**2. AI not using the tool:**
- Make sure tool description is clear
- Add explicit instruction to use search_products
- Test with direct commands like "search for tubes"

**3. Fields are undefined:**
- Not all products have all fields
- Use fallbacks: `{Prix} || "Prix non disponible"`
- Check field names match exactly (case-sensitive)

**4. Timeout errors:**
- Increase API timeout to 10-15 seconds
- Large result sets may take longer

### Debug Tips:

1. **Test API directly** with PowerShell:
```powershell
$body = @{ query = "tubes" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://serverlessvoiceflow.vercel.app/api/voiceflow/search" -Method POST -Body $body -ContentType "application/json"
```

2. **Check Voiceflow logs:**
   - View API request/response in debug panel
   - Verify response structure matches expectations

3. **Use console.log in code blocks:**
```javascript
console.log('Products:', products);
console.log('First product:', products[0]);
```

---

## 🎉 You're Ready!

**Your API is live and ready:**
```
https://serverlessvoiceflow.vercel.app/api/voiceflow/search
```

**Features:**
- ✅ Full text search across all product fields
- ✅ Returns ALL database fields (prices, volumes, sizes, etc.)
- ✅ No result limits - complete dataset
- ✅ Perfect for AI agent processing
- ✅ French language support
- ✅ Real-time MongoDB data

**Choose your approach:**
- 🤖 **AI Agent** (Recommended) - Natural conversations, automatic understanding
- 🔧 **Traditional Flow** - Full control, manual configuration

Happy building! 🚀

---

## 📚 Additional Endpoints

### Browse All Products
```
POST https://serverlessvoiceflow.vercel.app/api/voiceflow/browse
Body: { "category": "optional", "brand": "optional" }
```

Returns complete catalog with category/brand filtering options.

### Health Check
```
GET https://serverlessvoiceflow.vercel.app/api/voiceflow/search
```

Returns API status and MongoDB connection info.

