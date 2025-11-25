# Voiceflow Quick Setup - 5 Minutes

## 🚀 Fastest Way to Get Started

### Step 1: Add Blocks to Canvas (2 minutes)

In Voiceflow, add these blocks in order:

```
1. [Text Block] 
   └─ "Bonjour! Que cherchez-vous?"

2. [Capture Block]
   └─ Variable name: user_query
   └─ Wait for user input

3. [API Block] ⭐ THIS IS THE IMPORTANT ONE
   └─ See configuration below

4. [Text Block]
   └─ Display: {search_speech}

5. [Choice Block]
   └─ "Chercher autre chose?"
       ├─ Oui → Loop back to block 1
       └─ Non → End conversation
```

### Step 2: Configure the API Block (3 minutes)

Click on the **API Block** and enter:

#### Basic Settings:
```
Method: POST
URL: https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

#### Headers Section:
Click "+ Add Header"
```
Key: Content-Type
Value: application/json
```

#### Body Section:
Select "Raw Input" or "JSON", then paste:
```json
{
  "query": "{user_query}"
}
```

#### Response Section:
Click "+ Add Mapping" twice to add:

**Mapping 1:**
```
Path: speech
Variable: search_speech (create new)
```

**Mapping 2:**
```
Path: results
Variable: search_results (create new)
```

### Step 3: Test! 🧪

Click the **Test** button (usually top-right in Voiceflow)

Try these queries:
- "masque"
- "pipette"
- "CORNING"

You should get French responses with product results!

---

## 🎯 That's It!

Your basic integration is complete. The bot will now search your 70,230 products!

---

## 📸 Visual Guide

### Where to find the API Block:

```
Left Sidebar → Logic Section → API (drag to canvas)
```

### API Block Configuration Panel (appears on right):

```
┌─────────────────────────────────────┐
│ API REQUEST                         │
├─────────────────────────────────────┤
│ Method: [POST ▼]                    │
│                                     │
│ URL:                                │
│ https://serverless-voiceflow-...    │
│                                     │
│ Headers: [+ Add Header]             │
│ ┌───────────────────────────────┐   │
│ │ Content-Type: application/json│   │
│ └───────────────────────────────┘   │
│                                     │
│ Body:                               │
│ ┌───────────────────────────────┐   │
│ │ {                             │   │
│ │   "query": "{user_query}"     │   │
│ │ }                             │   │
│ └───────────────────────────────┘   │
├─────────────────────────────────────┤
│ RESPONSE MAPPING                    │
├─────────────────────────────────────┤
│ [+ Add Mapping]                     │
│                                     │
│ Path: speech                        │
│ Variable: search_speech             │
│                                     │
│ Path: results                       │
│ Variable: search_results            │
└─────────────────────────────────────┘
```

---

## 🔄 Alternative: Use {last_utterance}

If you don't want to use a Capture block, you can use Voiceflow's built-in `{last_utterance}` variable:

**API Body:**
```json
{
  "query": "{last_utterance}"
}
```

This captures whatever the user just said without needing a separate Capture block.

---

## ✅ Checklist

Before testing, verify:

- [ ] API Method is **POST** (not GET)
- [ ] URL is correct (no typos)
- [ ] Header `Content-Type: application/json` is added
- [ ] Body JSON has `"query": "{user_query}"` or `"{last_utterance}"`
- [ ] Response mapping includes `speech` → `search_speech`
- [ ] You have a Text block to display `{search_speech}`

---

## 🎉 Success Criteria

When you test, you should see:

**You:** "masque"
**Bot:** "J'ai trouvé 10 produits: Lunette - masque Uvex ultravison faceguard..."

If you see this, **congratulations!** Your integration is working! 🚀

---

## 🆘 Troubleshooting

**Problem:** "API call failed"
- ✅ Check your internet connection
- ✅ Verify the URL is exactly correct
- ✅ Make sure headers are added

**Problem:** "Variable not found"
- ✅ Make sure you created the `search_speech` variable
- ✅ Check the variable name matches in both places

**Problem:** Bot says nothing
- ✅ Make sure you have a Text block after the API block
- ✅ Make sure the Text block displays `{search_speech}`

**Problem:** Getting empty responses
- ✅ Make sure the Body JSON is correct
- ✅ Verify `{user_query}` or `{last_utterance}` is captured

---

Need more help? Check the full guide: `VOICEFLOW-INTEGRATION-GUIDE.md`

