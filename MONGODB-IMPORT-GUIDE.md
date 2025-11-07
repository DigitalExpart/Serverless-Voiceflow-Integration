# Guide d'importation MongoDB - 70,230 Produits

## ✅ Fichiers prêts

- ✅ `products-data.json` - 70,230 produits (130 MB)
- ✅ `atlas-search-index-produits.json` - Configuration de l'index de recherche
- ✅ API mise à jour pour les champs français

## 📝 Étape 1: Créer votre cluster MongoDB Atlas

### Si vous n'avez pas encore de compte:

1. Allez sur: https://www.mongodb.com/cloud/atlas/register
2. Créez un compte gratuit
3. Créez un cluster (Free Tier M0 - Gratuit)
4. Choisissez une région proche de vous

### Configuration du cluster:

1. **Database Access** (Sécurité → Database Access):
   - Cliquez "Add New Database User"
   - Nom d'utilisateur: `voiceflow_user` (ou votre choix)
   - Mot de passe: Créez un mot de passe fort
   - Privilèges: "Read and write to any database"
   - Cliquez "Add User"

2. **Network Access** (Sécurité → Network Access):
   - Cliquez "Add IP Address"
   - **IMPORTANT**: Sélectionnez "Allow Access from Anywhere" (`0.0.0.0/0`)
   - C'est requis pour Vercel
   - Cliquez "Confirm"

## 📥 Étape 2: Importer les données

### Option A: Utiliser MongoDB Compass (Interface graphique - Recommandé)

1. **Télécharger MongoDB Compass**:
   - https://www.mongodb.com/try/download/compass
   - Installez-le

2. **Se connecter**:
   - Dans MongoDB Atlas → Database → Connect
   - Choisissez "Compass"
   - Copiez la connection string
   - Collez-la dans Compass
   - Remplacez `<password>` par votre mot de passe

3. **Créer la base de données**:
   - Cliquez "Create Database"
   - Database name: `voiceflow_db`
   - Collection name: `produits`
   - Cliquez "Create Database"

4. **Importer les données**:
   - Sélectionnez la collection `produits`
   - Cliquez "ADD DATA" → "Import JSON or CSV file"
   - Sélectionnez `products-data.json`
   - **IMPORTANT**: Cochez "Select Input File Type" → JSON Array
   - Cliquez "Import"
   - ⏳ Attendez quelques minutes (70,230 documents)

### Option B: Utiliser mongoimport (Ligne de commande)

```bash
# Remplacez les valeurs par vos informations
mongoimport --uri "mongodb+srv://voiceflow_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/voiceflow_db" \
  --collection produits \
  --file products-data.json \
  --jsonArray
```

**Pour Windows PowerShell**:
```powershell
mongoimport --uri "mongodb+srv://voiceflow_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/voiceflow_db" --collection produits --file products-data.json --jsonArray
```

## 🔍 Étape 3: Créer l'index Atlas Search

1. **Dans MongoDB Atlas**:
   - Database → Search (onglet)
   - Cliquez "Create Search Index"

2. **Configuration**:
   - Choose Configuration Method: "JSON Editor"
   - Cliquez "Next"

3. **Sélection**:
   - Database: `voiceflow_db`
   - Collection: `produits`

4. **Index Definition**:
   - Collez le contenu de `atlas-search-index-produits.json`:

```json
{
  "mappings": {
    "dynamic": false,
    "fields": {
      "Reference": {
        "type": "string",
        "analyzer": "lucene.keyword"
      },
      "Designation": {
        "type": "string",
        "analyzer": "lucene.french"
      },
      "Description": {
        "type": "string",
        "analyzer": "lucene.french"
      },
      "Marque": {
        "type": "string",
        "analyzer": "lucene.standard"
      },
      "Categorie racine": {
        "type": "string",
        "analyzer": "lucene.french"
      },
      "Sous-categorie 1": {
        "type": "string",
        "analyzer": "lucene.french"
      },
      "Sous-categorie 2": {
        "type": "string",
        "analyzer": "lucene.french"
      },
      "Sous-categorie 3": {
        "type": "string",
        "analyzer": "lucene.french"
      },
      "Reference du fabricant": {
        "type": "string",
        "analyzer": "lucene.keyword"
      }
    }
  }
}
```

5. **Finaliser**:
   - Index Name: `default`
   - Cliquez "Create Search Index"
   - ⏳ Attendez 1-2 minutes pour que l'index devienne actif (statut vert)

## 🔧 Étape 4: Configurer les variables d'environnement Vercel

1. Allez sur: https://vercel.com/the-new-alkebulan/serverless-api/settings/environment-variables

2. Ajoutez ces variables:

### MONGO_URI
```
mongodb+srv://voiceflow_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
```
*Remplacez par votre connection string réelle*

### DB_NAME
```
voiceflow_db
```

### COLLECTION_NAME
```
produits
```

### SEARCH_INDEX_NAME
```
default
```

3. **Sélectionnez les environnements**:
   - ✓ Production
   - ✓ Preview
   - ✓ Development

4. **Redéployer**:
   - Allez dans l'onglet "Deployments"
   - Cliquez sur le menu ⋯ du dernier déploiement
   - Cliquez "Redeploy"

## 🧪 Étape 5: Tester l'API

Une fois le redéploiement terminé, testez avec PowerShell:

```powershell
# Test 1: Recherche de masque
$body = @{ query = "masque" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json" | ConvertTo-Json -Depth 10

# Test 2: Recherche par marque
$body = @{ query = "CORNING" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json" | ConvertTo-Json -Depth 10

# Test 3: Recherche par catégorie
$body = @{ query = "pipetage" } | ConvertTo-Json
Invoke-RestMethod -Uri "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json" | ConvertTo-Json -Depth 10
```

### Résultat attendu:

```json
{
  "speech": "J'ai trouvé 10 produits: Masque en tissu, ...",
  "results": [
    {
      "reference": "000282",
      "designation": "Masque en tissu",
      "description": "• Catégorie 2...",
      "marque": "DIVERS DUTSCHER",
      "categorie": "Sécurité",
      "sous_categorie": "protection respiratoire",
      "reference_fabricant": "716/CAIRVP**",
      "score": 8.5
    }
  ]
}
```

## 🎯 Étape 6: Intégration Voiceflow

### Configuration du bloc API dans Voiceflow:

1. **Ajouter un bloc API**
2. **Configurer**:
   - **Method**: POST
   - **URL**: `https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search`
   - **Headers**: 
     ```
     Content-Type: application/json
     ```
   - **Body**:
     ```json
     {
       "query": "{last_utterance}"
     }
     ```

3. **Mapper la réponse**:
   - Créez une variable pour stocker `{response.speech}`
   - Utilisez-la dans un bloc Text pour parler les résultats
   - Stockez `{response.results}` pour afficher les détails des produits

### Exemple de flow Voiceflow:

```
User: "Je cherche un masque"
  ↓
[Capture Intent]
  ↓
[API Call] → POST avec {"query": "masque"}
  ↓
[Response] → Stocker dans variable {search_results}
  ↓
[Text Block] → Dire: {search_results.speech}
  ↓
[Optional] → Afficher les premiers résultats avec détails
```

## 📊 Statistiques de votre base de données

- **Total de produits**: 70,230
- **Catégories principales**: Sécurité, Pipetage, etc.
- **Champs indexés pour la recherche**:
  - Reference (recherche exacte)
  - Designation (texte français)
  - Description (texte français)
  - Marque (texte standard)
  - Catégories (texte français)

## ✅ Checklist finale

- [ ] Cluster MongoDB Atlas créé
- [ ] Utilisateur de base de données créé
- [ ] IP whitelist configurée (0.0.0.0/0)
- [ ] 70,230 produits importés dans la collection `produits`
- [ ] Index Atlas Search créé et actif (statut vert)
- [ ] Variables d'environnement ajoutées à Vercel
- [ ] Application redéployée sur Vercel
- [ ] Tests API réussis
- [ ] Intégration Voiceflow configurée

## 🆘 Dépannage

### Erreur de connexion MongoDB:
- Vérifiez que 0.0.0.0/0 est dans la whitelist IP
- Vérifiez le mot de passe dans MONGO_URI
- Vérifiez que l'utilisateur a les bonnes permissions

### Aucun résultat de recherche:
- Attendez 1-2 minutes que l'index Search devienne actif
- Vérifiez que les 70,230 documents sont bien importés
- Testez une recherche simple comme "masque" ou "pipette"

### Erreur 500:
- Vérifiez les logs Vercel: https://vercel.com/the-new-alkebulan/serverless-api/logs
- Vérifiez que toutes les variables d'environnement sont définies
- Vérifiez que le nom de la collection est correct: `produits`

## 📞 Support

Si vous rencontrez des problèmes, vérifiez:
1. Les logs Vercel
2. L'état de l'index Atlas Search (doit être vert)
3. La connexion MongoDB dans Compass

Bonne chance! 🚀

