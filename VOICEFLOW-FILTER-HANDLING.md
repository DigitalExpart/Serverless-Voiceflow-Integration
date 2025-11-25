# How to Handle Filter Selection in Voiceflow

## 📊 Current Situation

When the API finds >5 results, it returns:
- `step: "needs_filter"`
- `filters` object with brands, categories, sous_categories
- `speech` message with filter options

## 🎯 What to Do in Voiceflow

### Option 1: Use Choice Block (Recommended)

After your API block, add a **Condition Block** to check `{search_step}`:

**If `search_step == "needs_filter"`:**

1. **Text Block:** Display `{search_speech}`
   - This shows the filter options

2. **Choice Block:** Create buttons from filters
   - **Option 1:** "Filter by Brand"
   - **Option 2:** "Filter by Category"  
   - **Option 3:** "Show All" (skip filtering)

3. **If "Filter by Brand" selected:**
   - **Choice Block:** Show brands from `{search_filters.brands}`
   - Create buttons for each brand (e.g., "BELLCO", "THERMO SCIENTIFIC")
   - On selection → Call API with filter

4. **API Block:** Apply filter
   - **Body:**
     ```json
     {
       "step": "apply_filter",
       "query": "{original_query}",
       "brand": null,
       "filter_type": "brand",
       "filter_value": "{selected_brand}"
     }
     ```

### Option 2: Use AI Block (More Natural)

1. **AI Block** after API
   - **System Prompt:**
     ```
     The user searched for products and got {search_total_count} results. 
     Available filters are in {search_filters}.
     
     Ask the user which filter they want to use:
     - Brand (list available brands)
     - Category (list available categories)
     - Or show all results
     
     Once they choose, help them select a specific value.
     ```
   
   - **Knowledge Base:** Include `{search_filters}` variable
   - **Capture:** User's filter choice
   - **Call API:** With selected filter

### Option 3: Simple Response (Quick Fix)

**User Response Options:**

1. **"BELLCO"** or any brand name
   - Voiceflow captures this
   - Calls API with `step: "search_with_brand"` and `brand: "BELLCO"`

2. **"Show me all"** or **"No filter"**
   - Skip to showing first 5 results
   - Or show all (if you want to allow it)

3. **"Filter by category"**
   - Show category options
   - User selects → Apply filter

---

## 🔄 Complete Flow Example

```
[User: "test tube"]
  ↓
[API: smart-search, step="initial"]
  ↓
[Condition: search_step == "needs_filter"?]
  ↓ YES
[Text: Display {search_speech}]
  ↓
[Choice: "Filter by Brand" | "Filter by Category" | "Show All"]
  ↓
[If "Filter by Brand"]
  [Choice: Show brands from {search_filters.brands}]
    ↓
  [API: smart-search, step="apply_filter", filter_type="brand"]
    ↓
  [Check result step again]
```

---

## 📝 Response Mapping

Make sure you're mapping these from the API response:

- `step` → `search_step`
- `speech` → `search_speech`
- `filters` → `search_filters`
- `total_count` → `search_total_count`
- `original_query` → `original_query`

---

## 🧪 Testing

**Test Query:** "test tube"

**Expected API Response:**
```json
{
  "step": "needs_filter",
  "speech": "J'ai trouvé 100 produits. Pour affiner la recherche, choisissez un filtre:\n\n**Marques:** BELLCO (25), THERMO SCIENTIFIC (20)...",
  "filters": {
    "brands": [
      { "name": "BELLCO", "count": 25 },
      { "name": "THERMO SCIENTIFIC", "count": 20 }
    ],
    "categories": [...],
    "sous_categories": [...]
  },
  "total_count": 100,
  "original_query": "test tube"
}
```

**User Can Respond:**
- "BELLCO" → Filter by brand
- "Filter by category" → Show categories
- "Show all" → Skip filtering (show first 5)

---

## ✅ Quick Setup

1. **Add Condition Block** after API
2. **Check:** `{search_step} == "needs_filter"`
3. **If True:**
   - Show `{search_speech}` (filter options)
   - Add Choice Block with filter options
   - On selection → Call API with filter
4. **If False:** Continue to show results

---

## 💡 Pro Tip

You can use **Voiceflow's AI Block** to make this more conversational:

- AI can understand "I want BELLCO" or "Show me BELLCO products"
- AI can extract the brand/category from natural language
- More user-friendly than buttons

