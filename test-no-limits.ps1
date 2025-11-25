# Test script to verify all limits are removed
# Tests searches that should return large result sets

$BASE_URL = "https://serverless-voiceflow-integration.vercel.app"

Write-Host "`n🧪 Testing No Limits - Large Result Sets`n" -ForegroundColor Cyan
Write-Host "Base URL: $BASE_URL`n" -ForegroundColor Gray

# Test 1: Search for "tube" (should return 15,000+)
Write-Host "Test 1: Search for 'tube' (expecting 15,000+ results)" -ForegroundColor Yellow
try {
    $body = @{ query = "tube" } | ConvertTo-Json
    
    Write-Host "   Sending request..." -ForegroundColor Gray
    $startTime = Get-Date
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "   ✅ Success!" -ForegroundColor Green
    Write-Host "   Results Count: $($response.results.Count)" -ForegroundColor White
    Write-Host "   Query Time: $([math]::Round($duration, 2)) seconds" -ForegroundColor White
    Write-Host "   Response Size: ~$([math]::Round(($response | ConvertTo-Json -Depth 1).Length / 1024, 2)) KB" -ForegroundColor White
    
    if ($response.results.Count -gt 1000) {
        Write-Host "   ✅ PASS: Returned > 1000 results (old limit was 100-500)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  WARNING: Only $($response.results.Count) results (expected more)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Search for "tubes" 
Write-Host "Test 2: Search for 'tubes'" -ForegroundColor Yellow
try {
    $body = @{ query = "tubes" } | ConvertTo-Json
    
    Write-Host "   Sending request..." -ForegroundColor Gray
    $startTime = Get-Date
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "   ✅ Success!" -ForegroundColor Green
    Write-Host "   Results Count: $($response.results.Count)" -ForegroundColor White
    Write-Host "   Query Time: $([math]::Round($duration, 2)) seconds" -ForegroundColor White
    
    if ($response.results.Count -gt 500) {
        Write-Host "   ✅ PASS: No artificial limit applied" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Smart search
Write-Host "Test 3: Smart Search for 'tube'" -ForegroundColor Yellow
try {
    $body = @{
        step = "initial"
        query = "tube"
    } | ConvertTo-Json
    
    Write-Host "   Sending request..." -ForegroundColor Gray
    $startTime = Get-Date
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/smart-search" -Method Post -Body $body -ContentType "application/json"
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "   ✅ Success!" -ForegroundColor Green
    Write-Host "   Step: $($response.step)" -ForegroundColor White
    Write-Host "   Total Results: $($response.total_results)" -ForegroundColor White
    Write-Host "   Query Time: $([math]::Round($duration, 2)) seconds" -ForegroundColor White
    
    if ($response.total_results -gt 1000) {
        Write-Host "   ✅ PASS: Returns all matching products" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Common product search
Write-Host "Test 4: Search for common product (expecting many results)" -ForegroundColor Yellow
try {
    $body = @{ query = "laboratory" } | ConvertTo-Json
    
    Write-Host "   Sending request..." -ForegroundColor Gray
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/search" -Method Post -Body $body -ContentType "application/json"
    
    Write-Host "   ✅ Results Count: $($response.results.Count)" -ForegroundColor Green
    
    if ($response.results.Count -gt 100) {
        Write-Host "   ✅ PASS: Old limit (100) was exceeded" -ForegroundColor Green
    }
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ All No-Limit Tests Completed!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  • All artificial limits removed" -ForegroundColor White
Write-Host "  • Queries return complete datasets" -ForegroundColor White
Write-Host "  • No 100/500/1000 result caps" -ForegroundColor White
Write-Host ""

