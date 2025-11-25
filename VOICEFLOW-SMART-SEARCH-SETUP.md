# How to Use Smart Search in Voiceflow

## ✅ The Endpoint is Already Added!

The `POST /api/voiceflow/smart-search` endpoint is **already implemented** in your code at:
- **File:** `api/voiceflow/search.js`
- **Line:** ~600

You don't need to add it - it's already there! You just need to:

1. **Deploy it** to Vercel
2. **Use it** in Voiceflow

---

## 🚀 Step 1: Deploy to Vercel

```powershell
vercel --prod
```

This will deploy the new endpoint.

---

## 🎯 Step 2: Use in Voiceflow

### Option A: Replace Your Current Search

**In Voiceflow, update your API Block:**

1. **Change the URL:**
   ```
   FROM: https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
   TO:   https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search
   ```

2. **Update the Body:**
   ```json
   {
     "step": "initial",
     "query": "{user_query}"
   }
   ```

3. **Update Response Mapping:**
   - `step` → `search_step`
   - `speech` → `search_speech`
   - `results` → `search_results`
   - `needs_brand` → `needs_brand` (if step is "ask_brand")
   - `filters` → `search_filters` (if step is "needs_filter")

---

## 🔄 Step 3: Handle Multi-Step Flow

### Flow Structure:

```
[Start]
  ↓
[Capture: user_query]
  ↓
[API: smart-search, step="initial"]
  ↓
[Condition: Check search_step]
  ├─ "ask_brand" → [Capture: brand] → [API: smart-search, step="search_with_brand"]
  ├─ "needs_filter" → [Choice: Select filter] → [API: smart-search, step="apply_filter"]
  ├─ "final" → [Display results]
  └─ "no_results" → [Show suggestions]
```

---

## 📋 Detailed Voiceflow Setup

### Block 1: Capture User Query

**Type:** Capture Block
- **Variable:** `user_query`
- **Wait for user input**

### Block 2: Initial Search

**Type:** API Block
- **Method:** `POST`
- **URL:** `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/smart-search`
- **Headers:**
  - `Content-Type: application/json`
- **Body:**
  ```json
  {
    "step": "initial",
    "query": "{user_query}"
  }
  ```
- **Response Mapping:**
  - `step` → `search_step`
  - `speech` → `search_speech`
  - `results` → `search_results`
  - `needs_brand` → `needs_brand`
  - `original_query` → `original_query`
  - `filters` → `search_filters`

### Block 3: Condition - Check Step

**Type:** Condition Block
- **Condition:** `{search_step} == "ask_brand"`
- **If True:** Go to "Ask Brand" block
- **If False:** Check next condition

**Add more conditions:**
- `{search_step} == "needs_filter"` → Go to "Filter Selection"
- `{search_step} == "final"` → Go to "Show Results"
- `{search_step} == "no_results"` → Go to "Show Suggestions"

### Block 4: Ask for Brand (if needed)

**Type:** Text Block
- **Content:** `{search_speech}`

**Type:** Capture Block
- **Variable:** `user_brand`
- **Wait for user input**

**Type:** API Block
- **Method:** `POST`
- **URL:** Same as above
- **Body:**
  ```json
  {
    "step": "search_with_brand",
    "query": "{original_query}",
    "brand": "{user_brand}"
  }
  ```
- **Response Mapping:** Same as Block 2

### Block 5: Filter Selection (if >5 results)

**Type:** Text Block
- **Content:** `{search_speech}`

**Type:** Choice Block
- **Options:** Create buttons from `{search_filters.brands}` or `{search_filters.categories}`
- **On Selection:** Store selected filter in variable

**Type:** API Block
- **Method:** `POST`
- **URL:** Same as above
- **Body:**
  ```json
  {
    "step": "apply_filter",
    "query": "{original_query}",
    "brand": "{user_brand}",
    "filter_type": "brand",
    "filter_value": "{selected_filter}"
  }
  ```
- **Response Mapping:** Same as Block 2
- **Loop back** to Condition Block to check if still needs filter

### Block 6: Show Final Results

**Type:** Text Block
- **Content:** `{search_speech}`

**Type:** Cards/List Block (optional)
- **Display:** `{search_results}`
- **Show:** Reference, Brand, Designation

---

## 🧪 Testing

### Test 1: Query without brand
```json
{
  "step": "initial",
  "query": "glass tube"
}
```

**Expected:** Returns `step: "ask_brand"`

### Test 2: Query with brand
```json
{
  "step": "search_with_brand",
  "query": "glass tube",
  "brand": "BELLCO"
}
```

**Expected:** Returns results or asks for filter

### Test 3: Apply filter
```json
{
  "step": "apply_filter",
  "query": "glass tube",
  "brand": "BELLCO",
  "filter_type": "brand",
  "filter_value": "BELLCO"
}
```

**Expected:** Returns filtered results (≤5 products)

---

## ✅ Summary

1. ✅ Endpoint is already in your code
2. ✅ Deploy with `vercel --prod`
3. ✅ Update Voiceflow API Block URL to `/smart-search`
4. ✅ Update body to include `"step": "initial"`
5. ✅ Handle different steps with Condition blocks
6. ✅ Loop filter selection until ≤5 results

---

## 📚 More Info

See `SMART-SEARCH-GUIDE.md` for complete API documentation.

