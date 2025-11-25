# Smart Search API Guide

## 🎯 Overview

The smart search endpoint implements a multi-step search flow that:
1. Receives user query
2. Asks for brand if not provided
3. Searches MongoDB (all words must appear in same product)
4. Groups results if >5 found
5. Applies filters until ≤5 results
6. Displays final results (Reference, Brand, Designation only)

---

## 📡 Endpoint

```
POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search
```

---

## 🔄 Flow Steps

### Step 1: Initial Query

**Request:**
```json
{
  "step": "initial",
  "query": "I'm looking for a glass tube"
}
```

**Response (if brand not mentioned):**
```json
{
  "step": "ask_brand",
  "speech": "Je comprends que vous cherchez \"I'm looking for a glass tube\". Connaissez-vous la marque du produit? Cela m'aiderait à affiner la recherche.",
  "results": [],
  "needs_brand": true,
  "original_query": "I'm looking for a glass tube"
}
```

**Response (if brand found in query):**
- Proceeds directly to search

---

### Step 2: Search with Brand

**Request:**
```json
{
  "step": "search_with_brand",
  "query": "glass tube",
  "brand": "BELLCO"
}
```

**Response (1-5 results):**
```json
{
  "step": "final",
  "speech": "J'ai trouvé 3 produits correspondant à votre recherche de la marque BELLCO.",
  "results": [
    {
      "reference": "508231",
      "brand": "BELLCO",
      "designation": "Tubes à sceller par capsule aluminium"
    },
    {
      "reference": "508232",
      "brand": "BELLCO",
      "designation": "Tube à sceller avec bouchon caoutchouc bleu"
    }
  ],
  "total_count": 3
}
```

**Response (>5 results):**
```json
{
  "step": "needs_filter",
  "speech": "J'ai trouvé 25 produits. Pour affiner la recherche, choisissez un filtre:\n\n**Marques:** BELLCO (15), THERMO SCIENTIFIC (10)\n**Catégories:** Consommable (20), Petit équipement (5)\n**Sous-catégories:** tube (25)",
  "results": [],
  "filters": {
    "brands": [
      { "name": "BELLCO", "count": 15 },
      { "name": "THERMO SCIENTIFIC", "count": 10 }
    ],
    "categories": [
      { "name": "Consommable", "count": 20 },
      { "name": "Petit équipement", "count": 5 }
    ],
    "sous_categories": [
      { "name": "tube", "count": 25 }
    ]
  },
  "total_count": 25,
  "original_query": "glass tube",
  "brand": "BELLCO"
}
```

---

### Step 3: Apply Filter

**Request:**
```json
{
  "step": "apply_filter",
  "query": "glass tube",
  "brand": "BELLCO",
  "filter_type": "brand",
  "filter_value": "BELLCO"
}
```

**Response:**
- Re-searches with filter applied
- Returns results (1-5, or asks for another filter if still >5)

---

### Step 4: No Results

**Response:**
```json
{
  "step": "no_results",
  "speech": "Je n'ai trouvé aucun produit correspondant à \"xyz\". Pouvez-vous reformuler votre recherche ou essayer d'autres mots-clés?",
  "results": [],
  "suggestions": [
    "Essayez des mots-clés plus généraux",
    "Vérifiez l'orthographe",
    "Essayez une autre marque",
    "Utilisez des synonymes"
  ]
}
```

---

## 🔍 Search Logic

### Smart Search Requirements

- **All keywords** must appear in the **same product**
- Searches across these fields:
  - `Sous-categorie 1`
  - `Sous-categorie 2`
  - `Sous-categorie 3`
  - `Designation`
  - `Description`
  - `Marque`

### Example

Query: "glass tube"

**Matches:** Products where BOTH "glass" AND "tube" appear somewhere in the product (can be in different fields)

**Does NOT match:** 
- Product with only "glass" (missing "tube")
- Product with only "tube" (missing "glass")

---

## 📊 Result Management

### 0 Results
- Suggests rephrasing
- Provides helpful suggestions

### 1-5 Results
- Shows directly
- Displays: Reference, Brand, Designation

### >5 Results
- Groups by: Brand, Category, Sous-catégorie, Material
- Asks user to choose a filter
- Repeats until ≤5 results

---

## 🎯 Voiceflow Integration

### Flow Structure

```
[Start]
  ↓
[Capture: user_query]
  ↓
[API: smart-search, step="initial"]
  ↓
[Condition: Check step]
  ├─ "ask_brand" → [Capture: brand] → [API: smart-search, step="search_with_brand"]
  ├─ "needs_filter" → [Choice: Select filter] → [API: smart-search, step="apply_filter"]
  ├─ "final" → [Display results]
  └─ "no_results" → [Show suggestions]
```

### API Block Configuration

**Step 1 (Initial):**
- Method: `POST`
- URL: `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search`
- Body:
```json
{
  "step": "initial",
  "query": "{user_query}"
}
```

**Step 2 (With Brand):**
- Body:
```json
{
  "step": "search_with_brand",
  "query": "{original_query}",
  "brand": "{user_brand}"
}
```

**Step 3 (Apply Filter):**
- Body:
```json
{
  "step": "apply_filter",
  "query": "{original_query}",
  "brand": "{brand}",
  "filter_type": "brand",
  "filter_value": "{selected_filter}"
}
```

### Response Mapping

**Variables to create:**
- `search_step` ← `response.step`
- `search_speech` ← `response.speech`
- `search_results` ← `response.results`
- `search_filters` ← `response.filters`
- `search_suggestions` ← `response.suggestions`

---

## 🧪 Testing

### Test 1: Query without brand
```bash
curl -X POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search \
  -H "Content-Type: application/json" \
  -d '{"step": "initial", "query": "glass tube"}'
```

### Test 2: Query with brand
```bash
curl -X POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search \
  -H "Content-Type: application/json" \
  -d '{"step": "search_with_brand", "query": "glass tube", "brand": "BELLCO"}'
```

### Test 3: Apply filter
```bash
curl -X POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search \
  -H "Content-Type: application/json" \
  -d '{"step": "apply_filter", "query": "glass tube", "brand": "BELLCO", "filter_type": "brand", "filter_value": "BELLCO"}'
```

---

## ✅ Features

- ✅ Smart search: All words must match in same product
- ✅ Brand extraction from query
- ✅ Brand prompting if not provided
- ✅ Automatic result grouping
- ✅ Multi-step filtering
- ✅ Final display: Max 5 products (Reference, Brand, Designation only)
- ✅ Helpful suggestions for no results

---

## 🔧 Filter Types

- `brand` - Filter by brand name
- `category` - Filter by "Categorie racine"
- `sous_categorie` - Filter by "Sous-categorie 1"
- `material` - Filter by material (extracted from description)

---

## 📝 Notes

- Search is case-insensitive
- Minimum keyword length: 3 characters
- All keywords must appear in the same product
- Results are limited to 100 initially, then filtered down
- Final display shows only essential fields: Reference, Brand, Designation

