# Script to push changes to GitHub with proper authentication
# This will help you authenticate with your DigitalExpart account

Write-Host "🔐 GitHub Push Helper" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# Check if we have pending commits
$status = git status --porcelain
if ($status) {
    Write-Host "⚠️ You have uncommitted changes. Committing first..." -ForegroundColor Yellow
    git add .
    git commit -m "Add Excel converter and French product data (70,230 products)"
}

Write-Host "📊 Local commits waiting to push:" -ForegroundColor Cyan
git log origin/main..HEAD --oneline

Write-Host ""
Write-Host "================================" -ForegroundColor Yellow
Write-Host "AUTHENTICATION OPTIONS" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Option 1: Use Personal Access Token (Recommended)" -ForegroundColor Green
Write-Host "   1. Go to: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "   2. Click 'Generate new token' → 'Generate new token (classic)'" -ForegroundColor White
Write-Host "   3. Name: Voiceflow API" -ForegroundColor White
Write-Host "   4. Select scope: ✓ repo (full control)" -ForegroundColor White
Write-Host "   5. Click 'Generate token' and COPY it" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Do you have a Personal Access Token? (y/n)"

if ($choice -eq 'y' -or $choice -eq 'Y') {
    Write-Host ""
    $token = Read-Host "Paste your Personal Access Token" -AsSecureString
    $tokenPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))
    
    Write-Host ""
    Write-Host "🔄 Updating remote with token..." -ForegroundColor Yellow
    
    # Update remote URL with token
    git remote set-url origin "https://$tokenPlain@github.com/DigitalExpart/Serverless-Voiceflow-Integration.git"
    
    Write-Host "✅ Remote updated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Cyan
    
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "================================" -ForegroundColor Green
        Write-Host "✅ SUCCESS! Changes pushed to GitHub!" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "View your repository:" -ForegroundColor Cyan
        Write-Host "https://github.com/DigitalExpart/Serverless-Voiceflow-Integration" -ForegroundColor White
        Write-Host ""
        Write-Host "Your changes include:" -ForegroundColor Cyan
        Write-Host "  ✓ Excel to JSON converter" -ForegroundColor White
        Write-Host "  ✓ 70,230 products in JSON format" -ForegroundColor White
        Write-Host "  ✓ Updated API for French product data" -ForegroundColor White
        Write-Host "  ✓ MongoDB import guide" -ForegroundColor White
        Write-Host "  ✓ Atlas Search index configuration" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "❌ Push failed. Please check the error above." -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "Please create a Personal Access Token first:" -ForegroundColor Yellow
    Write-Host "1. Open: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "2. Generate a new token with 'repo' scope" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "Opening GitHub settings in browser..." -ForegroundColor Cyan
    Start-Process "https://github.com/settings/tokens"
}

