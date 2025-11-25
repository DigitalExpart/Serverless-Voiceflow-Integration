# MongoDB Import Helper Script
# This script will help you import your 70,230 products to MongoDB Atlas

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  MongoDB Data Import Helper" -ForegroundColor Cyan
Write-Host "  70,230 Products Ready to Import" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if products-data.json exists
if (-not (Test-Path "products-data.json")) {
    Write-Host "❌ Error: products-data.json not found!" -ForegroundColor Red
    Write-Host "Make sure the file is in the current directory." -ForegroundColor Yellow
    exit
}

$fileSize = (Get-Item "products-data.json").Length / 1MB
Write-Host "✅ Found: products-data.json ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
Write-Host ""

# Count records
Write-Host "📊 Counting records..." -ForegroundColor Yellow
$jsonContent = Get-Content "products-data.json" -Raw | ConvertFrom-Json
$recordCount = $jsonContent.Count
Write-Host "✅ Records to import: $recordCount" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Import Method Selection" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Choose your import method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. MongoDB Compass (GUI - Easiest) ⭐ RECOMMENDED" -ForegroundColor Green
Write-Host "   - Visual interface" -ForegroundColor Gray
Write-Host "   - Easy to use" -ForegroundColor Gray
Write-Host "   - See data as you import" -ForegroundColor Gray
Write-Host ""
Write-Host "2. mongoimport (Command Line - Faster)" -ForegroundColor Cyan
Write-Host "   - Faster for large datasets" -ForegroundColor Gray
Write-Host "   - Requires MongoDB tools installed" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Enter choice (1 or 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Method 1: MongoDB Compass" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if Compass is installed
    $compassPaths = @(
        "$env:LOCALAPPDATA\Programs\mongosh\MongoDBCompass.exe",
        "$env:PROGRAMFILES\MongoDB\Compass\MongoDBCompass.exe",
        "$env:PROGRAMFILES\MongoDB Compass\MongoDBCompass.exe"
    )
    
    $compassFound = $false
    foreach ($path in $compassPaths) {
        if (Test-Path $path) {
            $compassFound = $true
            Write-Host "✅ MongoDB Compass found!" -ForegroundColor Green
            Write-Host ""
            $launch = Read-Host "Launch MongoDB Compass now? (y/n)"
            if ($launch -eq 'y' -or $launch -eq 'Y') {
                Start-Process $path
            }
            break
        }
    }
    
    if (-not $compassFound) {
        Write-Host "MongoDB Compass not found. Would you like to download it?" -ForegroundColor Yellow
        $download = Read-Host "(y/n)"
        if ($download -eq 'y' -or $download -eq 'Y') {
            Start-Process "https://www.mongodb.com/try/download/compass"
        }
    }
    
    Write-Host ""
    Write-Host "📋 Step-by-Step Instructions:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Step 1: Get your MongoDB connection string" -ForegroundColor Yellow
    Write-Host "   - In MongoDB Atlas → Database → Connect" -ForegroundColor White
    Write-Host "   - Choose 'Compass'" -ForegroundColor White
    Write-Host "   - Copy the connection string" -ForegroundColor White
    Write-Host ""
    Write-Host "Step 2: Connect in Compass" -ForegroundColor Yellow
    Write-Host "   - Paste connection string" -ForegroundColor White
    Write-Host "   - Replace <password> with your password" -ForegroundColor White
    Write-Host "   - Click 'Connect'" -ForegroundColor White
    Write-Host ""
    Write-Host "Step 3: Create Database" -ForegroundColor Yellow
    Write-Host "   - Click 'Create Database'" -ForegroundColor White
    Write-Host "   - Database name: voiceflow_db" -ForegroundColor Green
    Write-Host "   - Collection name: produits" -ForegroundColor Green
    Write-Host "   - Click 'Create Database'" -ForegroundColor White
    Write-Host ""
    Write-Host "Step 4: Import Data" -ForegroundColor Yellow
    Write-Host "   - Select the 'produits' collection" -ForegroundColor White
    Write-Host "   - Click 'ADD DATA' → 'Import JSON or CSV file'" -ForegroundColor White
    Write-Host "   - Select: products-data.json" -ForegroundColor Green
    Write-Host "   - IMPORTANT: Check 'Select Input File Type' → 'JSON Array' ✓" -ForegroundColor Red
    Write-Host "   - Click 'Import'" -ForegroundColor White
    Write-Host "   - Wait 2-5 minutes for 70,230 documents to import" -ForegroundColor White
    Write-Host ""
    Write-Host "File location: $PWD\products-data.json" -ForegroundColor Cyan
    Write-Host ""
    
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Method 2: mongoimport (CLI)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if mongoimport is installed
    try {
        $version = mongoimport --version 2>$null
        Write-Host "✅ mongoimport found!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "❌ mongoimport not found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Download MongoDB Database Tools:" -ForegroundColor Yellow
        Write-Host "https://www.mongodb.com/try/download/database-tools" -ForegroundColor White
        Write-Host ""
        $download = Read-Host "Open download page? (y/n)"
        if ($download -eq 'y' -or $download -eq 'Y') {
            Start-Process "https://www.mongodb.com/try/download/database-tools"
        }
        exit
    }
    
    Write-Host "Enter your MongoDB connection details:" -ForegroundColor Cyan
    Write-Host ""
    
    $uri = Read-Host "MongoDB URI (e.g., mongodb+srv://user:pass@cluster.mongodb.net/)"
    $dbName = Read-Host "Database name (press Enter for 'voiceflow_db')"
    if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = "voiceflow_db" }
    
    $collName = Read-Host "Collection name (press Enter for 'produits')"
    if ([string]::IsNullOrWhiteSpace($collName)) { $collName = "produits" }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  Ready to Import" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Database: $dbName" -ForegroundColor Cyan
    Write-Host "Collection: $collName" -ForegroundColor Cyan
    Write-Host "Records: $recordCount" -ForegroundColor Cyan
    Write-Host "File: products-data.json" -ForegroundColor Cyan
    Write-Host ""
    
    $confirm = Read-Host "Start import? (y/n)"
    
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        Write-Host ""
        Write-Host "🚀 Starting import..." -ForegroundColor Green
        Write-Host "This may take 2-5 minutes for 70,230 documents..." -ForegroundColor Yellow
        Write-Host ""
        
        $startTime = Get-Date
        
        # Run mongoimport
        mongoimport --uri $uri --db $dbName --collection $collName --file "products-data.json" --jsonArray
        
        if ($LASTEXITCODE -eq 0) {
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalSeconds
            
            Write-Host ""
            Write-Host "═══════════════════════════════════════" -ForegroundColor Green
            Write-Host "  ✅ IMPORT SUCCESSFUL!" -ForegroundColor Green
            Write-Host "═══════════════════════════════════════" -ForegroundColor Green
            Write-Host ""
            Write-Host "Records imported: $recordCount" -ForegroundColor Cyan
            Write-Host "Time taken: $([math]::Round($duration, 2)) seconds" -ForegroundColor Cyan
            Write-Host "Database: $dbName" -ForegroundColor Cyan
            Write-Host "Collection: $collName" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Next step: Create Atlas Search Index" -ForegroundColor Yellow
            Write-Host "See: MONGODB-IMPORT-GUIDE.md (Step 3)" -ForegroundColor White
        } else {
            Write-Host ""
            Write-Host "❌ Import failed. Check the error above." -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Need help? Check:" -ForegroundColor White
Write-Host "  - MONGODB-IMPORT-GUIDE.md (Full guide)" -ForegroundColor Gray
Write-Host "  - MongoDB Atlas Dashboard" -ForegroundColor Gray
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

