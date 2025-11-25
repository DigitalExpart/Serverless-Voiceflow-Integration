# MongoDB Data Import Helper
# This script will help you import 70,230 products to MongoDB Atlas

Write-Host "📊 MongoDB Data Import Helper" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Check if products-data.json exists
if (!(Test-Path "products-data.json")) {
    Write-Host "❌ Error: products-data.json not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "The data file should have been created when you converted the Excel file." -ForegroundColor Yellow
    Write-Host "Please run: node convert-excel-to-json.js produits(1).xlsx" -ForegroundColor White
    exit 1
}

$fileSize = [math]::Round((Get-Item "products-data.json").Length / 1MB, 2)
Write-Host "✅ Found: products-data.json ($fileSize MB)" -ForegroundColor Green
Write-Host ""

# Get MongoDB connection details
Write-Host "🔐 MongoDB Configuration" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "I need your MongoDB Atlas connection information." -ForegroundColor Yellow
Write-Host ""

# Check if already configured in .env
if (Test-Path ".env") {
    Write-Host "Found .env file. Checking configuration..." -ForegroundColor Yellow
    $envContent = Get-Content ".env" -Raw
    
    if ($envContent -match "mongodb\+srv://") {
        Write-Host "✅ MongoDB URI found in .env" -ForegroundColor Green
        Write-Host ""
        Write-Host "Using configuration from .env file" -ForegroundColor Cyan
        Write-Host ""
        
        $useEnv = Read-Host "Use .env configuration? (y/n)"
        if ($useEnv -eq 'y' -or $useEnv -eq 'Y') {
            Write-Host ""
            Write-Host "🚀 Starting import..." -ForegroundColor Cyan
            Write-Host ""
            node import-to-mongodb.js
            exit $LASTEXITCODE
        }
    }
}

Write-Host "Please provide your MongoDB connection details:" -ForegroundColor Cyan
Write-Host ""

# Get MongoDB URI
Write-Host "1. MongoDB Connection String (URI)" -ForegroundColor Yellow
Write-Host "   Example: mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/" -ForegroundColor Gray
Write-Host ""
$mongoUri = Read-Host "   Enter your MongoDB URI"

if ($mongoUri -eq "") {
    Write-Host ""
    Write-Host "❌ MongoDB URI is required!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To get your connection string:" -ForegroundColor Yellow
    Write-Host "1. Go to MongoDB Atlas → Database → Connect" -ForegroundColor White
    Write-Host "2. Choose 'Connect your application'" -ForegroundColor White
    Write-Host "3. Copy the connection string" -ForegroundColor White
    Write-Host "4. Replace <password> with your actual password" -ForegroundColor White
    exit 1
}

Write-Host ""

# Get database name
Write-Host "2. Database Name" -ForegroundColor Yellow
$dbName = Read-Host "   Enter database name (default: voiceflow_db)"
if ($dbName -eq "") { $dbName = "voiceflow_db" }

Write-Host ""

# Get collection name
Write-Host "3. Collection Name" -ForegroundColor Yellow
$collectionName = Read-Host "   Enter collection name (default: produits)"
if ($collectionName -eq "") { $collectionName = "produits" }

Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Database: $dbName" -ForegroundColor White
Write-Host "Collection: $collectionName" -ForegroundColor White
Write-Host "Records to import: 70,230" -ForegroundColor White
Write-Host "File size: $fileSize MB" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Proceed with import? (y/n)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Import cancelled." -ForegroundColor Yellow
    exit 0
}

# Set environment variables and run import
Write-Host ""
Write-Host "🚀 Starting import..." -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$env:MONGO_URI = $mongoUri
$env:DB_NAME = $dbName
$env:COLLECTION_NAME = $collectionName

node import-to-mongodb.js

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=============================" -ForegroundColor Green
    Write-Host "✅ Import completed successfully!" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Create Atlas Search Index" -ForegroundColor White
    Write-Host "   - Go to MongoDB Atlas → Database → Search" -ForegroundColor Gray
    Write-Host "   - Create index using atlas-search-index-produits.json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Update Vercel environment variables with:" -ForegroundColor White
    Write-Host "   MONGO_URI = $mongoUri" -ForegroundColor Gray
    Write-Host "   DB_NAME = $dbName" -ForegroundColor Gray
    Write-Host "   COLLECTION_NAME = $collectionName" -ForegroundColor Gray
    Write-Host "   SEARCH_INDEX_NAME = default" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Redeploy on Vercel" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Import failed. Please check the error above." -ForegroundColor Red
    Write-Host ""
}

