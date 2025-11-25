# Test script for adding products to MongoDB
# Usage: .\test-add-product.ps1

$BASE_URL = "https://serverless-voiceflow-integration.vercel.app"

Write-Host "`n🧪 Testing Add Product Endpoints`n" -ForegroundColor Cyan
Write-Host "Base URL: $BASE_URL`n" -ForegroundColor Gray

# Test 1: Add Single Product
Write-Host "Test 1: Add Single Product" -ForegroundColor Yellow
try {
    $product = @{
        Reference = "TEST-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Designation = "Test Product - PowerShell"
        Description = "This is a test product added via API"
        Marque = "TEST_BRAND"
        "Categorie racine" = "Test Category"
        "Sous-categorie 1" = "Test Subcategory"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/add-product" -Method Post -Body $product -ContentType "application/json"
    
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "   Reference: $($response.reference)" -ForegroundColor White
    Write-Host "   Designation: $($response.designation)" -ForegroundColor White
    Write-Host "   Message: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Yellow
    }
}
Write-Host ""

# Test 2: Add Multiple Products
Write-Host "Test 2: Add Multiple Products (Bulk)" -ForegroundColor Yellow
try {
    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    $body = @{
        products = @(
            @{
                Reference = "BULK-$timestamp-1"
                Designation = "Bulk Product 1"
                Marque = "BULK_BRAND"
                "Categorie racine" = "Bulk Category"
            },
            @{
                Reference = "BULK-$timestamp-2"
                Designation = "Bulk Product 2"
                Marque = "BULK_BRAND"
                "Categorie racine" = "Bulk Category"
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/add-products" -Method Post -Body $body -ContentType "application/json"
    
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host "   Inserted: $($response.inserted_count)" -ForegroundColor White
    Write-Host "   Total Requested: $($response.total_requested)" -ForegroundColor White
    Write-Host "   Message: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Try to add duplicate (should fail)
Write-Host "Test 3: Try to add duplicate product (should fail)" -ForegroundColor Yellow
try {
    $product = @{
        Reference = "DUPLICATE-TEST"
        Designation = "Duplicate Test"
        Marque = "TEST"
    } | ConvertTo-Json

    # Add first time
    Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/add-product" -Method Post -Body $product -ContentType "application/json" | Out-Null
    Write-Host "   First add: ✅ Success" -ForegroundColor Green
    
    # Try to add again (should fail)
    try {
        Invoke-RestMethod -Uri "$BASE_URL/api/voiceflow/add-product" -Method Post -Body $product -ContentType "application/json" | Out-Null
        Write-Host "   Second add: ❌ Should have failed!" -ForegroundColor Red
    } catch {
        Write-Host "   Second add: ✅ Correctly rejected (duplicate)" -ForegroundColor Green
    }
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "✅ All tests completed!`n" -ForegroundColor Green

