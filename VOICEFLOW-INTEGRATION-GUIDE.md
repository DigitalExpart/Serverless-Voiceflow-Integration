# Voiceflow Integration Guide
## Complete Setup for MongoDB Product Search

### 🎯 Your API Endpoint
```
https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

---

## 📋 Complete Voiceflow Flow Example

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
[Condition: Check if results found]
  ├─ Yes → [Text Block: Show {search_speech}]
  └─ No → [Text Block: "Aucun produit trouvé"]
```

---

## 🔧 Detailed Configuration

### 1. Text Block (Welcome Message)
```
Bonjour! Je peux vous aider à trouver des produits.
Que recherchez-vous? (par exemple: masque, pipette, ou une marque comme CORNING)
```

### 2. Capture Block
- **Variable Name**: `user_query`
- **Type**: Text
- **Wait for user response**

### 3. API Block Configuration

**Request Setup:**
- **Method**: `POST`
- **URL**: `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search`

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

Create these variables to store the response:

| Response Path | Variable Name | Description |
|---------------|---------------|-------------|
| `speech` | `search_speech` | The French text response |
| `results` | `search_results` | Array of product objects |
| `results[0].reference` | `first_product_ref` | First product reference |
| `results[0].designation` | `first_product_name` | First product name |
| `results[0].marque` | `first_product_brand` | First product brand |

### 4. Condition Block (Check Results)

**Condition:**
```
{search_results}.length > 0
```

**If TRUE** (Products found):
- Go to "Show Results" block

**If FALSE** (No products):
- Go to "No Results" block

### 5. Text Block (Show Results)

**Simple version:**
```
{search_speech}
```

**Detailed version:**
```
{search_speech}

Le premier produit est:
Nom: {first_product_name}
Référence: {first_product_ref}
Marque: {first_product_brand}

Voulez-vous plus de détails?
```

### 6. Text Block (No Results)

```
Je n'ai trouvé aucun produit correspondant à "{user_query}".
Voulez-vous essayer une autre recherche?
```

---

## 🎨 Advanced: Display Multiple Products

### Using a Card Block for Each Product:

If you want to show multiple products nicely, you can create cards:

**Card 1:**
- **Title**: `{search_results[0].designation}`
- **Description**: `Référence: {search_results[0].reference}`
- **Footer**: `Marque: {search_results[0].marque}`

**Card 2:**
- **Title**: `{search_results[1].designation}`
- **Description**: `Référence: {search_results[1].reference}`
- **Footer**: `Marque: {search_results[1].marque}`

And so on...

---

## 🔄 Alternative: Use Carousel for Products

Create a **Carousel Block** to show multiple products:

**For each card in carousel:**
- **Image**: Product image (if available)
- **Title**: `{designation}`
- **Subtitle**: `{marque}`
- **Description**: First 100 chars of `{description}`
- **Button**: "Plus de détails" → Link to product page or show full description

---

## 🧪 Testing Your Voiceflow Bot

### Test Queries:

1. **"masque"** 
   - Should return: ~10 mask/protection products

2. **"pipette"**
   - Should return: ~10 pipetting products

3. **"CORNING"**
   - Should return: ~10 CORNING brand products

4. **"sécurité"**
   - Should return: Safety/security category products

5. **"Reference: 000282"**
   - Should return: Specific product by reference number

---

## 🎯 Example Conversation Flow

**User:** "Bonjour"

**Bot:** "Bonjour! Je peux vous aider à trouver des produits. Que recherchez-vous?"

**User:** "Je cherche un masque"

**Bot:** "J'ai trouvé 10 produits: Lunette - masque Uvex ultravison faceguard, Demi-masque Moldex 7000, Demi-masque Moldex 7000...

Le premier produit est:
Nom: Lunette - masque Uvex ultravison faceguard - PC incolore / UV2 - 1,2
Référence: 267009
Marque: UVEX

Voulez-vous plus de détails ou chercher autre chose?"

**User:** "Montrez-moi des produits CORNING"

**Bot:** "J'ai trouvé 10 produits: Plaque 384 puits Corning traitée Corning CellBIND..."

---

## 🔐 API Response Structure

Your API returns this format:

```json
{
  "speech": "J'ai trouvé 10 produits: Product1, Product2...",
  "results": [
    {
      "reference": "267009",
      "designation": "Lunette - masque Uvex...",
      "description": "Masque en polycarbonate...",
      "marque": "UVEX",
      "categorie": "Sécurité",
      "sous_categorie": "protection des yeux",
      "reference_fabricant": "9301.555",
      "score": 8.41
    }
  ]
}
```

### Available Fields to Use:

- `speech` - Pre-formatted French response
- `results[].reference` - Product reference number
- `results[].designation` - Product name/designation
- `results[].description` - Full product description
- `results[].marque` - Brand name
- `results[].categorie` - Main category
- `results[].sous_categorie` - Sub-category
- `results[].reference_fabricant` - Manufacturer reference
- `results[].score` - Search relevance score (higher = better match)

---

## 💡 Pro Tips

### 1. Error Handling

Add an API error handler:

**If API call fails:**
```
Désolé, j'ai rencontré un problème technique. 
Veuillez réessayer dans quelques instants.
```

### 2. Empty Query Handling

Before calling the API, check if `{user_query}` is not empty:

```
IF {user_query} is empty:
  "Veuillez entrer un terme de recherche."
ELSE:
  Call API
```

### 3. Timeout Setting

In the API block, set timeout to **10 seconds** to allow for search processing.

### 4. Caching (Optional)

For better performance, you can cache common searches in Voiceflow variables.

### 5. Multi-language Support

Your API currently returns French responses. To add English:
- Create a variable `{language}` (default: "fr")
- Modify the API to accept language parameter
- Or create separate API endpoints for each language

---

## 🎬 Quick Start Template

Copy this into your Voiceflow canvas:

1. **Start Node**
2. **Text**: "Bonjour! Que cherchez-vous?"
3. **Capture**: variable `user_query`
4. **API Call**: 
   - POST to your endpoint
   - Body: `{"query": "{user_query}"}`
   - Map response `speech` to `search_speech`
5. **Text**: `{search_speech}`
6. **Choice**: "Chercher autre chose?" → Loop back to step 2

---

## 📞 Support

If you encounter issues:

1. **Test the API directly**: Use the PowerShell test script
2. **Check Voiceflow logs**: View API call logs in Voiceflow
3. **Verify variables**: Make sure variable names match exactly
4. **Check JSON syntax**: Ensure body JSON is valid

---

## 🎉 You're Ready!

Your MongoDB product search is now integrated with Voiceflow!

**API Endpoint:**
```
https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

**Products Available:** 70,230
**Language:** French
**Search Types:** Product names, brands, categories, references

Happy building! 🚀

