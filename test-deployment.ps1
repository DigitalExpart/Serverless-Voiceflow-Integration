# Test script for your deployed Voiceflow MongoDB Search API
# Deployment URL: https://serverless-voiceflow-integration.vercel.app

$BASE_URL = "https://serverless-voiceflow-integration.vercel.app"

Write-Host "🧪 Testing Voiceflow MongoDB Search API" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deployment: $BASE_URL" -ForegroundColor Green
Write-Host ""

# Test 1: Health Check (GET) - Tests MongoDB Connection
Write-Host "Test 1: Health Check (GET) - MongoDB Connection Test" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Get
    
    Write-Host "✅ API Status: $($health.status)" -ForegroundColor Green
    Write-Host "📡 Message: $($health.message)" -ForegroundColor Cyan
    Write-Host "🕐 Timestamp: $($health.timestamp)" -ForegroundColor Cyan
    Write-Host ""
    
    # Check MongoDB connection
    if ($health.mongodb.connected -eq $true) {
        Write-Host "✅ MongoDB: CONNECTED" -ForegroundColor Green
        Write-Host "   Database: $($health.mongodb.database)" -ForegroundColor White
        Write-Host "   Collection: $($health.mongodb.collection)" -ForegroundColor White
        Write-Host "   Search Index: $($health.mongodb.searchIndex)" -ForegroundColor White
        if ($health.mongodb.documentCount) {
            Write-Host "   Documents: $($health.mongodb.documentCount)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ MongoDB: DISCONNECTED" -ForegroundColor Red
        Write-Host "   Status: $($health.mongodb.status)" -ForegroundColor Yellow
        if ($health.mongodb.error) {
            Write-Host "   Error: $($health.mongodb.error)" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "⚠️  ACTION REQUIRED:" -ForegroundColor Yellow
        Write-Host "   1. Check environment variables in Vercel dashboard" -ForegroundColor White
        Write-Host "   2. Verify MongoDB Atlas network access (0.0.0.0/0)" -ForegroundColor White
        Write-Host "   3. Redeploy after fixing environment variables" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Full Response:" -ForegroundColor Cyan
    Write-Host ($health | ConvertTo-Json -Depth 10) -ForegroundColor Gray
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "   Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    }
}
Write-Host "`n"

# Test 2: Search for "laptop"
Write-Host "Test 2: Search for 'laptop'" -ForegroundColor Yellow
try {
    $body = @{ query = "laptop" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ Success" -ForegroundColor Green
    Write-Host "Speech: $($result.speech)" -ForegroundColor Cyan
    Write-Host "Results Count: $($result.results.Count)" -ForegroundColor Cyan
    if ($result.results.Count -gt 0) {
        Write-Host "Products found:" -ForegroundColor Cyan
        foreach ($product in $result.results) {
            Write-Host "  - $($product.name) (ID: $($product.product_id))" -ForegroundColor White
        }
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Note: Make sure environment variables are configured in Vercel" -ForegroundColor Yellow
}
Write-Host "`n"

# Test 3: Search for "phone"
Write-Host "Test 3: Search for 'phone'" -ForegroundColor Yellow
try {
    $body = @{ query = "phone" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ Success" -ForegroundColor Green
    Write-Host "Speech: $($result.speech)" -ForegroundColor Cyan
    Write-Host "Results Count: $($result.results.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host "`n"

# Test 4: Empty query
Write-Host "Test 4: Empty query validation" -ForegroundColor Yellow
try {
    $body = @{ query = "" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ Success" -ForegroundColor Green
    Write-Host "Speech: $($result.speech)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host "`n"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✨ Testing completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Your API Endpoint:" -ForegroundColor Cyan
Write-Host "$BASE_URL/api/voiceflow/search" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure environment variables in Vercel dashboard" -ForegroundColor White
Write-Host "2. Import sample data to MongoDB (see example-data.json)" -ForegroundColor White
Write-Host "3. Create Atlas Search index (see atlas-search-index.json)" -ForegroundColor White
Write-Host "4. Integrate with Voiceflow using the API endpoint above" -ForegroundColor White

