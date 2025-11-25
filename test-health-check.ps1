# Quick Health Check Test - MongoDB Connection
# This tests if your API can connect to MongoDB

$URL = "https://serverless-voiceflow-integration.vercel.app/api/voiceflow/search"

Write-Host "🔍 Testing MongoDB Connection..." -ForegroundColor Cyan
Write-Host "URL: $URL" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $URL -Method Get
    
    Write-Host "✅ API Status: $($response.status)" -ForegroundColor $(if ($response.status -eq 'ok') { 'Green' } else { 'Yellow' })
    
    if ($response.mongodb.connected) {
        Write-Host "✅ MongoDB: CONNECTED" -ForegroundColor Green
        Write-Host "   Database: $($response.mongodb.database)" -ForegroundColor White
        Write-Host "   Collection: $($response.mongodb.collection)" -ForegroundColor White
        if ($response.mongodb.documentCount) {
            Write-Host "   Documents: $($response.mongodb.documentCount)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ MongoDB: NOT CONNECTED" -ForegroundColor Red
        Write-Host "   Error: $($response.mongodb.error)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 Fix: Check environment variables in Vercel dashboard" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "Full Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "❌ Request Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Make sure:" -ForegroundColor Cyan
    Write-Host "   1. The API is deployed to Vercel" -ForegroundColor White
    Write-Host "   2. The URL is correct" -ForegroundColor White
}

