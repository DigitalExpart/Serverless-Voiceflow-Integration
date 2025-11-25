# Fix: Conversation Ending After Filter Options

## 🔴 Problem

The chat ends after showing filter options. User can't respond to select a filter.

## ✅ Solution: Add Capture Block in Voiceflow

### The Issue

When the API returns `step: "needs_filter"`, Voiceflow shows the message but doesn't wait for user input, so the conversation ends.

### Fix in Voiceflow

**After your API Block that shows filter options:**

1. **Add a Capture Block**
   - **Variable name:** `user_filter_choice`
   - **Wait for user input:** ✅ Yes
   - **Type:** Text

2. **Add a Condition Block** to check what user said:
   - Check if user mentioned a brand name
   - Check if user said "category" or "sous-categorie"
   - Check if user said "show all" or "any"

3. **Add API Block** to apply filter:
   - **Body:**
     ```json
     {
       "step": "apply_filter",
       "query": "{original_query}",
       "brand": null,
       "filter_type": "brand",
       "filter_value": "{user_filter_choice}"
     }
     ```

### Complete Flow

```
[API: smart-search, step="initial"]
  ↓
[Condition: search_step == "needs_filter"?]
  ↓ YES
[Text: Display {search_speech} - shows filter options]
  ↓
[Capture Block: user_filter_choice] ⭐ THIS IS MISSING!
  ↓
[AI Block or Condition: Extract filter choice]
  ↓
[API: smart-search, step="apply_filter"]
  ↓
[Check result step again]
```

---

## 🎯 Quick Fix (2 Minutes)

### Step 1: Add Capture Block

1. **After the Text Block** that shows filter options
2. **Add Capture Block:**
   - Variable: `user_filter_choice`
   - Wait for input: ✅ Yes

### Step 2: Add AI Block (Recommended)

**Or use AI Block to understand user's response:**

1. **Add AI Block** after Capture
2. **System Prompt:**
   ```
   The user is choosing a filter from these options:
   Brands: {search_filters.brands}
   Categories: {search_filters.categories}
   
   Extract which filter they want:
   - If they mention a brand name → filter_type: "brand", filter_value: brand name
   - If they mention a category → filter_type: "category", filter_value: category name
   - If they say "show all" → skip filtering
   
   Output the filter choice in a structured way.
   ```

3. **AI Block** extracts the choice
4. **Call API** with the extracted filter

---

## 🔄 Alternative: Use Choice Block

**Instead of Capture Block, use Choice Block:**

1. **Choice Block** with buttons:
   - "Filter by Brand"
   - "Filter by Category"
   - "Show All"

2. **On "Filter by Brand":**
   - Show another Choice Block with brand names from `{search_filters.brands}`
   - On selection → Call API with filter

3. **On "Filter by Category":**
   - Show category options
   - On selection → Call API with filter

---

## 📊 Database Status

**Good News:**
- ✅ Database has data (100+ results found)
- ✅ No tables/collections were deleted
- ✅ Search is working correctly

**Note:**
- Health check shows 1 document (this is a counting issue, not actual data loss)
- Actual search finds 100+ products, so data exists

---

## ✅ Checklist

- [ ] Add Capture Block after showing filter options
- [ ] Set "Wait for user input" = Yes
- [ ] Add Condition/AI Block to process user's choice
- [ ] Add API Block to apply filter
- [ ] Test: User should be able to respond after seeing filters

---

## 🧪 Test Flow

1. User: "test tube"
2. API: Shows filter options
3. **User should be able to respond here** ← This is where it's breaking
4. User: "BELLCO" or "Filter by brand"
5. API: Applies filter
6. API: Shows results (≤5 products)

---

## 💡 Pro Tip

Use **Voiceflow's AI Block** instead of Capture Block for better understanding:

- AI can understand: "I want BELLCO" or "Show me BELLCO products"
- AI can extract brand/category from natural language
- More user-friendly than structured responses

The key is: **After showing filter options, you MUST wait for user input!**

