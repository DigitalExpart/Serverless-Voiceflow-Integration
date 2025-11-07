# Quick conversion script for produits(1).xlsx
# This script will help you convert the Excel file to JSON

Write-Host "📊 Excel to JSON Converter" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if the Excel file exists
$excelFile = "produits(1).xlsx"

if (Test-Path $excelFile) {
    Write-Host "✅ Found: $excelFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔄 Converting to JSON..." -ForegroundColor Yellow
    
    # Run the conversion
    node convert-excel-to-json.js $excelFile products-data.json
    
} else {
    Write-Host "❌ File not found: $excelFile" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please copy your Excel file to this directory:" -ForegroundColor Yellow
    Write-Host "   $PWD" -ForegroundColor White
    Write-Host ""
    Write-Host "You can use one of these commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "From Downloads:" -ForegroundColor Yellow
    Write-Host "   Copy-Item `"`$env:USERPROFILE\Downloads\produits(1).xlsx`" -Destination `".`"" -ForegroundColor White
    Write-Host ""
    Write-Host "From Desktop:" -ForegroundColor Yellow
    Write-Host "   Copy-Item `"`$env:USERPROFILE\Desktop\produits(1).xlsx`" -Destination `".`"" -ForegroundColor White
    Write-Host ""
    Write-Host "From any location:" -ForegroundColor Yellow
    Write-Host "   Copy-Item `"C:\path\to\produits(1).xlsx`" -Destination `".`"" -ForegroundColor White
    Write-Host ""
    Write-Host "After copying, run this script again:" -ForegroundColor Cyan
    Write-Host "   .\convert-produits.ps1" -ForegroundColor White
}

