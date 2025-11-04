# PowerShell Examples for Testing the Voiceflow MongoDB Search API
# Replace YOUR_DEPLOYMENT_URL with your actual Vercel deployment URL

$BASE_URL = "https://your-project.vercel.app"
# For local testing, use: $BASE_URL = "http://localhost:3000"

Write-Host "🧪 Testing Voiceflow MongoDB Search API" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Basic search query
Write-Host "Test 1: Search for 'laptop'" -ForegroundColor Yellow
$body1 = @{ query = "laptop" } | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body1 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host "`n"

# Test 2: Search with different term
Write-Host "Test 2: Search for 'phone'" -ForegroundColor Yellow
$body2 = @{ query = "phone" } | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body2 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host "`n"

# Test 3: Empty query
Write-Host "Test 3: Empty query" -ForegroundColor Yellow
$body3 = @{ query = "" } | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body3 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host "`n"

# Test 4: Query with no results
Write-Host "Test 4: Query with no results" -ForegroundColor Yellow
$body4 = @{ query = "nonexistentproduct12345" } | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body4 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host "`n"

# Test 5: Search by category
Write-Host "Test 5: Search for 'audio'" -ForegroundColor Yellow
$body5 = @{ query = "audio" } | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body5 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host "`n"

# Test 6: Fuzzy search (typo)
Write-Host "Test 6: Fuzzy search - 'laptp' (typo for laptop)" -ForegroundColor Yellow
$body6 = @{ query = "laptp" } | ConvertTo-Json
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body6 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host "`n"

# Test 7: Health check (GET request)
Write-Host "Test 7: Health check" -ForegroundColor Yellow
Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Get | ConvertTo-Json -Depth 10
Write-Host "`n"

Write-Host "✅ All tests completed!" -ForegroundColor Green

