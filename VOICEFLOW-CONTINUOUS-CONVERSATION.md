# Fix: Allow Continuous Conversation After Search

## 🔴 Problem
The chat ends after showing search results, preventing follow-up questions.

## ✅ Solution: Add a Loop or AI Block

You have **3 options** to fix this:

---

## Option 1: Add a Loop with Choice Block (Simple)

### Flow Structure:
```
[Start]
  ↓
[Text Block: "Bonjour! Que cherchez-vous?"]
  ↓
[Capture Block: user_query]
  ↓
[API Block: Search Products]
  ↓
[Text Block: Display {search_speech}]
  ↓
[Choice Block: "Voulez-vous chercher autre chose?"]
  ├─ "Oui" / "Yes" → Loop back to Capture Block
  └─ "Non" / "No" → End conversation
```

### Steps:
1. **After your Text Block** (that shows results), add a **Choice Block**
2. **Question:** "Voulez-vous chercher autre chose?" or "Would you like to search for something else?"
3. **Options:**
   - "Oui" / "Yes" → Connect back to the **Capture Block** (or first Text Block)
   - "Non" / "No" → End conversation
4. **Connect the "Oui" path** back to create a loop

---

## Option 2: Use AI Block for Continuous Conversation (Recommended)

### Flow Structure:
```
[Start]
  ↓
[Text Block: "Bonjour! Je peux vous aider à trouver des produits."]
  ↓
[AI Block: Handle All Interactions]
  └─ System Prompt: See below
  └─ Knowledge Base: {search_results} (from API)
```

### AI Block Configuration:

**System Prompt:**
```
You are a helpful product search assistant. When the user asks about products:

1. If they mention a product name, brand, or category, call the API to search.
2. Use the search results to answer their questions.
3. Ask if they need more information or want to search for something else.
4. Keep the conversation natural and helpful.

Always be ready to help with follow-up questions about the products.
```

**How to Use API in AI Block:**
1. In the AI Block, add a **Function/Tool** that calls your API
2. Or use **Intent Detection** to trigger the API Block when user asks about products
3. Store `{search_results}` in a variable
4. Reference it in the AI Block's knowledge base

---

## Option 3: Intent-Based Flow (Advanced)

### Flow Structure:
```
[Start]
  ↓
[AI Block: Intent Detection]
  ├─ Intent: "search_product" → Go to Search Flow
  ├─ Intent: "ask_question" → Use AI with {search_results}
  └─ Intent: "end_conversation" → End
  ↓
[Search Flow]
  ↓
[API Block]
  ↓
[Store results in variable]
  ↓
[AI Block: Answer questions about results]
  └─ Can access {search_results} variable
  └─ Loop back to Intent Detection
```

---

## 🎯 Quick Fix (Easiest - 2 Minutes)

### Add This After Your Results Display:

1. **Add a Choice Block:**
   - Question: "Would you like to search for something else?"
   - Option 1: "Yes" → Connect to your **Capture Block**
   - Option 2: "No" → End conversation

2. **Or Use AI Block:**
   - After showing results, add an **AI Block**
   - System Prompt: "You are a product assistant. The user just saw search results. Answer their questions about the products or help them search for something else."
   - Enable **"Continue conversation"** option
   - Reference `{search_results}` in the context

---

## 🔄 Best Practice: Hybrid Approach

Combine both for the best experience:

```
[Start]
  ↓
[Text: Welcome message]
  ↓
[Capture: user_query]
  ↓
[API: Search]
  ↓
[Text: Display {search_speech}]
  ↓
[AI Block: Handle follow-ups]
  └─ System: "Answer questions about {search_results}"
  └─ Can search again if user asks
  ↓
[Choice: "Need anything else?"]
  ├─ Yes → Back to Capture
  └─ No → End
```

---

## 📝 Step-by-Step: Add Loop (Option 1)

1. **In Voiceflow canvas:**
   - Find your flow that ends after showing results
   - Click on the last block (Text Block showing results)

2. **Add Choice Block:**
   - Drag a **Choice Block** from the sidebar
   - Connect it after your results Text Block

3. **Configure Choice Block:**
   - **Question:** "Voulez-vous chercher autre chose?"
   - **Option 1:** "Oui" → Connect to your **Capture Block** (or first Text Block)
   - **Option 2:** "Non" → End conversation

4. **Create the Loop:**
   - Click on "Oui" option
   - Draw a connection line back to your **Capture Block**
   - This creates the loop!

5. **Test:**
   - Search for something
   - After results, say "Oui" or "Yes"
   - You should be able to search again!

---

## 🤖 Using AI Block for Natural Conversation (Option 2)

1. **Add AI Block** after your results display

2. **Configure AI Block:**
   - **System Prompt:**
     ```
     You are a product search assistant. The user just searched for products and received results stored in {search_results}. 
     
     You can:
     - Answer questions about the products
     - Help refine the search
     - Provide more details about specific products
     
     Always be helpful and ask if they need anything else.
     ```
   
   - **Knowledge Base:** Reference `{search_results}` variable
   - **Enable:** "Continue conversation" or "Allow follow-ups"

3. **Connect:**
   - After API Block → Store results → AI Block
   - AI Block can handle all follow-up questions
   - Add a Choice Block after AI for explicit "search again" option

---

## ✅ Testing Checklist

After implementing the fix:

- [ ] Search for a product
- [ ] See results
- [ ] Ask a follow-up question (should work!)
- [ ] Search for something else (should work!)
- [ ] Conversation doesn't end unexpectedly

---

## 🎯 Recommended Solution

**For best user experience, use Option 2 (AI Block):**

1. After API Block, add an **AI Block**
2. Give it access to `{search_results}`
3. It can handle:
   - Follow-up questions about products
   - New search requests
   - General conversation
4. Add a Choice Block as backup for explicit "search again"

This gives you the most natural, continuous conversation experience!

---

## 🆘 Still Having Issues?

**Problem:** Loop doesn't work
- ✅ Make sure you connected "Yes" option back to Capture Block
- ✅ Check that Capture Block is set to "Wait for user input"

**Problem:** AI Block doesn't have access to results
- ✅ Make sure `{search_results}` variable exists
- ✅ Reference it in AI Block's knowledge base or context
- ✅ Store results before AI Block runs

**Problem:** Conversation still ends
- ✅ Check for any "End conversation" blocks in the flow
- ✅ Make sure AI Block has "Continue conversation" enabled
- ✅ Verify no blocks are set to "Stop and wait" incorrectly

