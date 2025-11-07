/**
 * Excel to JSON Converter
 * Converts Excel (.xlsx) files to JSON format for MongoDB import
 * 
 * Usage:
 * node convert-excel-to-json.js <input-file.xlsx> [output-file.json]
 */

const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

// Get command line arguments
const args = process.argv.slice(2);

if (args.length === 0) {
  console.error('❌ Error: Please provide an Excel file to convert');
  console.log('\nUsage:');
  console.log('  node convert-excel-to-json.js <input-file.xlsx> [output-file.json]');
  console.log('\nExample:');
  console.log('  node convert-excel-to-json.js produits(1).xlsx products.json');
  process.exit(1);
}

const inputFile = args[0];
const outputFile = args[1] || inputFile.replace(/\.(xlsx|xls)$/i, '.json');

// Check if input file exists
if (!fs.existsSync(inputFile)) {
  console.error(`❌ Error: File "${inputFile}" not found`);
  console.log('\nMake sure the file is in the current directory or provide the full path.');
  process.exit(1);
}

console.log('📊 Excel to JSON Converter');
console.log('=========================\n');
console.log(`📁 Input:  ${inputFile}`);
console.log(`💾 Output: ${outputFile}\n`);

try {
  // Read the Excel file
  console.log('📖 Reading Excel file...');
  const workbook = XLSX.readFile(inputFile);
  
  // Get the first sheet name
  const sheetName = workbook.SheetNames[0];
  console.log(`📄 Processing sheet: "${sheetName}"`);
  
  // Get the worksheet
  const worksheet = workbook.Sheets[sheetName];
  
  // Convert to JSON
  console.log('🔄 Converting to JSON...');
  const jsonData = XLSX.utils.sheet_to_json(worksheet, {
    raw: false, // Don't keep raw values
    defval: null, // Default value for empty cells
    blankrows: false // Skip blank rows
  });
  
  console.log(`✅ Converted ${jsonData.length} rows\n`);
  
  // Display sample data (first 2 rows)
  if (jsonData.length > 0) {
    console.log('📋 Sample Data (first row):');
    console.log(JSON.stringify(jsonData[0], null, 2));
    
    if (jsonData.length > 1) {
      console.log('\n📋 Sample Data (second row):');
      console.log(JSON.stringify(jsonData[1], null, 2));
    }
    console.log('');
  }
  
  // Save to JSON file
  console.log(`💾 Saving to ${outputFile}...`);
  fs.writeFileSync(outputFile, JSON.stringify(jsonData, null, 2), 'utf8');
  
  console.log('✅ Conversion completed successfully!\n');
  
  // Display summary
  console.log('📊 Summary:');
  console.log(`   Total records: ${jsonData.length}`);
  console.log(`   Output file: ${outputFile}`);
  console.log(`   File size: ${(fs.statSync(outputFile).size / 1024).toFixed(2)} KB\n`);
  
  // Display field names
  if (jsonData.length > 0) {
    const fields = Object.keys(jsonData[0]);
    console.log('📝 Fields found:');
    fields.forEach((field, index) => {
      console.log(`   ${index + 1}. ${field}`);
    });
    console.log('');
  }
  
  console.log('🎉 Ready to import to MongoDB!');
  console.log('\nNext steps:');
  console.log(`   1. Review ${outputFile} to ensure data is correct`);
  console.log('   2. Import to MongoDB using MongoDB Compass or mongoimport');
  console.log(`   3. mongoimport --uri "your-connection-string" --collection products --file ${outputFile} --jsonArray`);
  
} catch (error) {
  console.error('❌ Error during conversion:', error.message);
  process.exit(1);
}

