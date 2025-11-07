# Complete Voiceflow Setup Guide
## Product Search & Browse Bot with LLM Intelligence

---

## 🎯 What You'll Build

A smart product assistant that can:
- Search 70,230 products by name, brand, category
- Browse entire catalog with category/brand filtering
- Use AI/LLM to answer questions about products
- Provide intelligent recommendations

---

## 📋 Voiceflow Flow Structure

```
START
  ↓
Welcome Message
  ↓
Main Menu (Choice)
  ├─ Search Products → Flow A
  └─ Browse Catalog → Flow B
```

---

## 🏗️ Step-by-Step Setup

### STEP 1: Create Welcome Block

**Block Type:** Text Block

**Content:**
```
Bonjour! Je suis votre assistant produits. 

Je peux vous aider à:
• Chercher des produits spécifiques
• Parcourir notre catalogue
• Vous recommander les meilleurs produits

Comment puis-je vous aider aujourd'hui?
```

---

### STEP 2: Create Main Menu

**Block Type:** Buttons/Choice Block

**Option 1:** "🔍 Chercher un produit"
- Connect to → FLOW A (Search)

**Option 2:** "📚 Parcourir le catalogue"
- Connect to → FLOW B (Browse)

**Option 3:** "ℹ️ En savoir plus"
- Connect to → Info Block

---

## 🔍 FLOW A: Product Search (Specific Query)

### A1. Ask for Search Query

**Block Type:** Text Block
```
Que cherchez-vous?
(Ex: "masque", "pipette", "CORNING", "produits de sécurité")
```

### A2. Capture User Input

**Block Type:** Capture Block
- **Variable name:** `search_query`
- **Input type:** Text

### A3. Call Search API

**Block Type:** API Block

**Configuration:**
```
Method: POST
URL: https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search

Headers:
  Content-Type: application/json

Body (Raw JSON):
{
  "query": "{search_query}",
  "limit": 200
}

Response Mapping:
  speech → search_speech (create new variable)
  results → search_results (create new variable)
```

### A4. Check if Results Found

**Block Type:** Condition (IF Block)

**Condition:**
```
{search_results}.length > 0
```

**If TRUE:**
- Go to A5 (Show Results)

**If FALSE:**
- Go to A6 (No Results)

### A5. Show Results with AI

**Block Type:** Text Block
```
{search_speech}

J'ai trouvé {search_results.length} produits. 
Que voulez-vous savoir sur ces résultats?
```

### A6. Capture Follow-up Question

**Block Type:** Capture Block
- **Variable name:** `user_question`
- **Input type:** Text

### A7. AI/LLM Analysis

**Block Type:** AI Set / GPT Block

**System Prompt:**
```
Tu es un expert en produits de laboratoire scientifique.
Tu as accès à une liste de produits trouvés lors d'une recherche.
Analyse ces produits et réponds aux questions de l'utilisateur de manière professionnelle et utile.
Si l'utilisateur demande des recommandations, suggère 2-3 produits maximum avec leurs références.
Sois précis, concis et mentionne toujours les références des produits.
```

**User Prompt:**
```
Recherche effectuée: "{search_query}"

Produits trouvés ({search_results.length} au total):
{search_results}

Question de l'utilisateur: {user_question}

Instructions:
- Analyse les produits disponibles
- Réponds à la question de manière précise
- Si demandé, recommande 2-3 produits avec leurs références
- Mentionne les marques et catégories pertinentes
- Sois concis (max 150 mots)
```

**Model:** GPT-4 or GPT-3.5-turbo
**Temperature:** 0.7
**Max Tokens:** 300

**Store Response:** `ai_response`

### A8. Display AI Response

**Block Type:** Text Block
```
{ai_response}
```

### A9. Follow-up Choice

**Block Type:** Buttons Block

**Options:**
1. "Autre question sur ces produits" → Go back to A6
2. "Nouvelle recherche" → Go back to A1
3. "Menu principal" → Go back to Main Menu

### A10. No Results Message

**Block Type:** Text Block
```
Je n'ai trouvé aucun produit correspondant à "{search_query}".

Suggestions:
• Vérifiez l'orthographe
• Essayez un terme plus général
• Utilisez le nom de la marque ou catégorie

Voulez-vous essayer une autre recherche?
```

**Connect to:** Choice → "Oui" (A1) / "Menu principal" (Main Menu)

---

## 📚 FLOW B: Browse Catalog

### B1. Explain Browse Options

**Block Type:** Text Block
```
Voulez-vous:
• Voir tout le catalogue avec recommandations
• Filtrer par catégorie
• Filtrer par marque
```

### B2. Browse Choice

**Block Type:** Buttons Block

**Option 1:** "🌟 Recommandations du catalogue"
- Connect to → B3 (Get All)

**Option 2:** "📁 Par catégorie"
- Connect to → B4 (Category Filter)

**Option 3:** "🏷️ Par marque"
- Connect to → B5 (Brand Filter)

### B3. Get All Products with Recommendations

**Block Type:** API Block

**Configuration:**
```
Method: POST
URL: https://serverless-voiceflow-integration.vercel.app/api/voiceflow/browse

Headers:
  Content-Type: application/json

Body (Raw JSON):
{}

Response Mapping:
  speech → browse_speech
  total_products → total_count
  categories → all_categories
  brands → all_brands
  top_5_recommendations → top_5
  all_products → catalog_products
```

**Go to:** B6 (Display Results)

### B4. Category Filter Flow

**B4a. Show Available Categories**

**Block Type:** Text Block
```
Voici les principales catégories disponibles:

Top 10 catégories:
1. Consommable (25,017 produits)
2. Equipement (8,723 produits)
3. Sécurité (6,822 produits)
4. Petit équipement (6,763 produits)
5. Pipetage (4,834 produits)
6. Bio-réactif (5,070 produits)
7. Chimie (4,687 produits)
8. Fourniture (6,592 produits)

Quelle catégorie vous intéresse?
```

**B4b. Capture Category**

**Block Type:** Capture Block
- **Variable:** `selected_category`

**B4c. Call Browse API with Category**

**Block Type:** API Block
```
Method: POST
URL: https://serverless-voiceflow-integration.vercel.app/api/voiceflow/browse

Body:
{
  "category": "{selected_category}"
}

Response Mapping: (same as B3)
```

**Go to:** B6 (Display Results)

### B5. Brand Filter Flow

**B5a. Show Available Brands**

**Block Type:** Text Block
```
Voici les principales marques disponibles:

Top 10 marques:
1. DIVERS DUTSCHER (11,603 produits)
2. CLEARLINE (2,569 produits)
3. EPPENDORF (1,418 produits)
4. CARLO ERBA (1,272 produits)
5. OHAUS (1,250 produits)
6. THERMO SCIENTIFIC (1,183 produits)
7. CORNING (1,200 produits)
8. NALGENE (1,125 produits)

Quelle marque vous intéresse?
```

**B5b. Capture Brand**

**Block Type:** Capture Block
- **Variable:** `selected_brand`

**B5c. Call Browse API with Brand**

**Block Type:** API Block
```
Method: POST
URL: https://serverless-voiceflow-integration.vercel.app/api/voiceflow/browse

Body:
{
  "brand": "{selected_brand}"
}

Response Mapping: (same as B3)
```

**Go to:** B6 (Display Results)

### B6. Display Browse Results

**Block Type:** Text Block
```
{browse_speech}

📊 Statistiques:
• Total: {total_count} produits
• {all_categories.length} catégories
• {all_brands.length} marques disponibles

🌟 Mes 5 recommandations pour vous:
```

### B7. Display Top 5 Recommendations

**Block Type:** Card Carousel or Multiple Cards

For each of the 5 recommendations, create a card:

**Card Template:**
```
Title: {top_5[0].designation}
Subtitle: {top_5[0].marque}
Description: Ref: {top_5[0].reference}
Category: {top_5[0].categorie}

Button: "Plus de détails"
```

Repeat for index [1], [2], [3], [4]

### B8. AI-Powered Questions

**Block Type:** Text Block
```
J'ai chargé {catalog_products.length} produits en mémoire.
Vous pouvez maintenant me poser des questions comme:

• "Quel est le meilleur produit pour..."
• "Compare les produits CORNING et EPPENDORF"
• "Recommande-moi 3 produits de sécurité"
• "Montre-moi les produits les moins chers"

Quelle est votre question?
```

### B9. Capture Catalog Question

**Block Type:** Capture Block
- **Variable:** `catalog_question`

### B10. AI Analysis of Catalog

**Block Type:** AI Set / GPT Block

**System Prompt:**
```
Tu es un expert conseil en produits de laboratoire.
Tu as accès au catalogue complet de produits avec leurs catégories et marques.
Analyse le catalogue et réponds aux questions de manière experte.
Recommande les meilleurs produits selon les critères demandés.
```

**User Prompt:**
```
Catalogue disponible:
- Total: {total_count} produits
- Catégories: {all_categories}
- Marques: {all_brands}

Produits détaillés (échantillon):
{catalog_products}

Question de l'utilisateur: {catalog_question}

Instructions:
- Analyse les produits disponibles
- Fournis une réponse experte et détaillée
- Recommande 2-4 produits spécifiques avec leurs références
- Mentionne les avantages de chaque recommandation
- Compare les options si pertinent
- Maximum 200 mots
```

**Model:** GPT-4
**Temperature:** 0.7
**Store Response:** `catalog_ai_response`

### B11. Display Catalog AI Response

**Block Type:** Text Block
```
{catalog_ai_response}
```

### B12. Follow-up Options

**Block Type:** Buttons Block

**Options:**
1. "Autre question sur le catalogue" → B9
2. "Voir d'autres catégories" → B4
3. "Voir d'autres marques" → B5
4. "Menu principal" → Main Menu

---

## 🎨 Advanced: Code Block for Custom Filtering

If you want more control, add a **Code Block** between API call and display:

```javascript
// Filter by price range (if you have price field)
const budget = {user_budget}; // e.g., 100
const affordable = {catalog_products}.filter(p => p.price <= budget);

// Filter by multiple criteria
const filtered = {catalog_products}.filter(p => 
  p.categorie === "Sécurité" && 
  p.marque === "CORNING"
);

// Sort by relevance (score)
const sorted = {search_results}.sort((a, b) => b.score - a.score);

// Get unique brands from results
const uniqueBrands = [...new Set({catalog_products}.map(p => p.marque))];

// Count products by category
const categoryCount = {};
{catalog_products}.forEach(p => {
  categoryCount[p.categorie] = (categoryCount[p.categorie] || 0) + 1;
});

// Return filtered results
return { 
  filtered_products: filtered,
  sorted_products: sorted,
  brands_list: uniqueBrands
};
```

---

## 🎯 Complete Flow Diagram

```
┌─────────────────────────────────────────┐
│          START / WELCOME                │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│         MAIN MENU (Choice)              │
│  1. 🔍 Search Products                  │
│  2. 📚 Browse Catalog                   │
│  3. ℹ️ Info                             │
└──────┬──────────────────────┬───────────┘
       ↓                      ↓
┌──────────────────┐   ┌──────────────────┐
│    FLOW A:       │   │    FLOW B:       │
│    SEARCH        │   │    BROWSE        │
└──────────────────┘   └──────────────────┘

FLOW A (Search):
  A1. Ask Query
  A2. Capture {search_query}
  A3. API Call /search
  A4. Check Results
  A5. Display {search_speech}
  A6. Ask Follow-up
  A7. AI Analysis
  A8. Display AI Response
  A9. Choice (Loop or Exit)

FLOW B (Browse):
  B1. Explain Options
  B2. Choose (All/Category/Brand)
  B3/B4/B5. API Call /browse
  B6. Display Results
  B7. Show Top 5 Cards
  B8. Prompt for Questions
  B9. Capture Question
  B10. AI Analysis
  B11. Display Response
  B12. Follow-up Choice
```

---

## 🔧 Variables You'll Create

### Search Flow Variables:
- `search_query` (Text) - User's search input
- `search_speech` (Text) - API response message
- `search_results` (Array) - List of found products
- `user_question` (Text) - Follow-up question
- `ai_response` (Text) - AI analysis response

### Browse Flow Variables:
- `selected_category` (Text) - Chosen category
- `selected_brand` (Text) - Chosen brand
- `browse_speech` (Text) - API response message
- `total_count` (Number) - Total products count
- `all_categories` (Array) - List of categories
- `all_brands` (Array) - List of brands
- `top_5` (Array) - Top 5 recommendations
- `catalog_products` (Array) - All products
- `catalog_question` (Text) - User question about catalog
- `catalog_ai_response` (Text) - AI response

---

## 💡 Pro Tips

### 1. Add Error Handling

After each API block, add a condition:
```
IF {search_results} exists
  → Continue
ELSE
  → Show error message
```

### 2. Add Typing Indicators

Before API calls, add:
```
[Typing Indicator Block] - 2 seconds
```
This shows the bot is "thinking"

### 3. Add Conversation Memory

Store user preferences:
```
{user_favorite_brand}
{user_favorite_category}
{last_search}
```

### 4. Add Quick Actions

In cards, add buttons:
- "Voir détails"
- "Comparer"
- "Ajouter au panier"

### 5. Optimize Token Usage

For large result sets, send only necessary fields to AI:
```javascript
// In Code Block before AI
const summary = {catalog_products}.slice(0, 50).map(p => ({
  ref: p.reference,
  nom: p.designation,
  marque: p.marque,
  cat: p.categorie
}));

return { product_summary: summary };
```

Then use `{product_summary}` in AI prompt instead of full `{catalog_products}`

---

## 🧪 Testing Your Bot

### Test Scenarios:

**Scenario 1: Simple Search**
1. Start bot
2. Choose "Search Products"
3. Enter "masque"
4. Ask "Quel est le moins cher?"
5. Verify AI gives good recommendation

**Scenario 2: Browse by Category**
1. Start bot
2. Choose "Browse Catalog"
3. Choose "By Category"
4. Enter "Pipetage"
5. Ask "Compare les produits CORNING et EPPENDORF"

**Scenario 3: Browse All**
1. Start bot
2. Choose "Browse Catalog"
3. Choose "Catalog Recommendations"
4. Ask "Recommande-moi des produits de sécurité"

---

## 📊 Expected Performance

- **Search Response Time:** 2-4 seconds
- **Browse Response Time:** 3-5 seconds
- **AI Analysis Time:** 5-8 seconds
- **Total Products Accessible:** 70,230
- **Products per Search:** Up to 500
- **Products per Browse:** Up to 1,000

---

## 🚀 You're Ready to Build!

Start with the basic search flow (FLOW A), test it thoroughly, then add the browse capability (FLOW B).

The AI/LLM integration is the magic that makes your bot intelligent - it can understand context, compare products, and make smart recommendations based on all the data you provide!

---

## 📞 Need Help?

Common issues:
- **API timeout:** Increase limit in API block settings
- **Variables not found:** Check spelling matches exactly
- **AI gives generic answers:** Provide more context in the prompt
- **Too slow:** Reduce number of products sent to AI

Good luck building! 🎉

