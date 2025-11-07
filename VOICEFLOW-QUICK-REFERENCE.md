# Voiceflow Quick Reference Card

## 🔗 Your API Endpoints

### 1️⃣ Search Endpoint (Specific Products)
```
POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search
```

**Body:**
```json
{
  "query": "{search_query}",
  "limit": 200
}
```

**Returns:**
- `speech` - French summary message
- `results` - Array of matching products (up to 200)

**Use When:** User searches for specific products

---

### 2️⃣ Browse Endpoint (Catalog Overview)
```
POST https://serverless-voiceflow-integration.vercel.app/api/voiceflow/browse
```

**Body Options:**

**Get All:**
```json
{}
```

**Filter by Category:**
```json
{
  "category": "Pipetage"
}
```

**Filter by Brand:**
```json
{
  "brand": "CORNING"
}
```

**Both:**
```json
{
  "category": "Sécurité",
  "brand": "MOLDEX"
}
```

**Returns:**
- `speech` - French summary
- `total_products` - Total count
- `categories` - Array of categories with counts
- `brands` - Array of brands with counts
- `top_5_recommendations` - Top 5 products
- `all_products` - Full product list (up to 1000)

**Use When:** User wants to browse or explore catalog

---

## 📋 Voiceflow Block Checklist

### ✅ Search Flow (5 blocks minimum)

1. **Text Block** - "Que cherchez-vous?"
2. **Capture Block** - Store in `{search_query}`
3. **API Block** - POST to `/search`
4. **Text Block** - Display `{search_speech}`
5. **AI Block** - Answer questions about `{search_results}`

### ✅ Browse Flow (5 blocks minimum)

1. **Text Block** - "Browse options..."
2. **API Block** - POST to `/browse`
3. **Text Block** - Display `{browse_speech}` and stats
4. **Cards** - Show `{top_5_recommendations}`
5. **AI Block** - Answer questions about `{catalog_products}`

---

## 🎯 Essential Variables to Create

| Variable Name | Type | Stores |
|---------------|------|--------|
| `search_query` | Text | User's search input |
| `search_results` | Array | Found products |
| `search_speech` | Text | API response message |
| `user_question` | Text | Follow-up question |
| `ai_response` | Text | AI answer |
| `catalog_products` | Array | All products from browse |
| `top_5` | Array | Top 5 recommendations |
| `all_categories` | Array | Category list |
| `all_brands` | Array | Brand list |

---

## 🤖 AI Block Configuration

### System Prompt Template:
```
Tu es un expert en produits de laboratoire scientifique.
Tu as accès à [une liste de produits / un catalogue].
Analyse les produits et réponds de manière professionnelle.
Recommande 2-3 produits maximum avec leurs références.
Sois précis et concis (max 150 mots).
```

### User Prompt Template:
```
Produits disponibles:
{search_results} 
OU
{catalog_products}

Question: {user_question}

Fournis une réponse experte avec des recommandations spécifiques.
```

**Model:** GPT-4 or GPT-3.5-turbo
**Temperature:** 0.7
**Max Tokens:** 300

---

## 📊 Product Data Structure

Each product has:
```json
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
```

---

## 🎨 Common Patterns

### Pattern 1: Search → AI Filter
```
[Search API] → {search_results}
  ↓
[AI]: "Montre seulement les produits CORNING"
  ↓
[AI Response]: Filtered list
```

### Pattern 2: Browse → AI Recommend
```
[Browse API] → {catalog_products}
  ↓
[AI]: "Recommande 3 produits de sécurité"
  ↓
[AI Response]: Top 3 with reasons
```

### Pattern 3: Compare
```
[Search/Browse] → {products}
  ↓
[AI]: "Compare CORNING et EPPENDORF"
  ↓
[AI Response]: Comparison table
```

---

## 💡 Quick Troubleshooting

### Issue: "Variable not found"
**Fix:** Create the variable in Voiceflow first, ensure exact spelling

### Issue: API timeout
**Fix:** Reduce `limit` parameter or increase timeout setting

### Issue: AI gives generic answers
**Fix:** Provide more product data in the prompt, be specific

### Issue: Too many tokens
**Fix:** Slice results: `{search_results}.slice(0, 50)`

### Issue: Can't access nested data
**Fix:** Use dot notation: `{search_results[0].designation}`

---

## 📱 Testing Commands

### Test Search API (PowerShell):
```powershell
$body = @{ query = "masque"; limit = 200 } | ConvertTo-Json
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
```

### Test Browse API (PowerShell):
```powershell
$body = @{ category = "Pipetage" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/browse" -Method Post -Body $body -ContentType "application/json"
```

---

## 🌟 Top 10 Categories (for reference)

1. **Consommable** - 25,017 products
2. **Equipement** - 8,723 products
3. **Sécurité** - 6,822 products
4. **Petit équipement** - 6,763 products
5. **Fourniture** - 6,592 products
6. **Bio-réactif** - 5,070 products
7. **Pipetage** - 4,834 products
8. **Chimie** - 4,687 products
9. **Chromatographie** - 398 products
10. **Autres** - Various

---

## 🏷️ Top 10 Brands (for reference)

1. **DIVERS DUTSCHER** - 11,603 products
2. **CLEARLINE** - 2,569 products
3. **EPPENDORF** - 1,418 products
4. **CARLO ERBA** - 1,272 products
5. **OHAUS** - 1,250 products
6. **THERMO SCIENTIFIC** - 1,183 products
7. **CORNING** - ~1,200 products
8. **NALGENE** - 1,125 products
9. **CPACHEM** - 1,088 products
10. **WHATMAN** - 1,048 products

---

## 📞 Support Links

- **Full Setup Guide:** `VOICEFLOW-COMPLETE-SETUP.md`
- **Quick Start:** `VOICEFLOW-QUICK-SETUP.md`
- **Integration Guide:** `VOICEFLOW-INTEGRATION-GUIDE.md`
- **GitHub Repo:** https://github.com/DigitalExpart/Serverless-Voiceflow-Integration

---

## ✅ Final Checklist

Before going live:

- [ ] Both API endpoints tested and working
- [ ] All variables created in Voiceflow
- [ ] Search flow complete with AI integration
- [ ] Browse flow complete with recommendations
- [ ] Error handling added
- [ ] Tested with real user queries
- [ ] AI responses are relevant and helpful
- [ ] Navigation between flows works
- [ ] Bot returns to main menu properly

---

**You're all set! Start building!** 🚀

