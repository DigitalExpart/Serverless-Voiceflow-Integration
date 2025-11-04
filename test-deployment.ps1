# Test script for your deployed Voiceflow MongoDB Search API
# Deployment URL: https://serverless-voiceflow-integration.vercel.app

$BASE_URL = "https://serverless-voiceflow-integration.vercel.app"

Write-Host "🧪 Testing Voiceflow MongoDB Search API" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deployment: $BASE_URL" -ForegroundColor Green
Write-Host ""

# Test 1: Health Check
Write-Host "Test 1: Health Check (GET)" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Get
    Write-Host "✅ Status: OK" -ForegroundColor Green
    Write-Host ($health | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
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

