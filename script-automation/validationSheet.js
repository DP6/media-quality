function validationCleanSheet() {
  let sheet = SpreadsheetApp.getActiveSpreadsheet()
  let cleanSheet = sheet.getSheetByName("Clean");
  let colExclude = cleanSheet.getRange('I2:I');
  let allCollums = cleanSheet.getRange('A2:K');
 
  var ruleIsFalse = SpreadsheetApp.newDataValidation().requireTextContains(false).build();
  colExclude.setDataValidation(ruleIsFalse);
  
  var ruleIsNaoexiste = SpreadsheetApp.newDataValidation().requireTextDoesNotContain('Não existe').build();
  var ruleSetColor = SpreadsheetApp.newConditionalFormatRule().whenTextContains('Não existe').setBackground('#F5A9BC').setRanges([allCollums]).build()

  allCollums.setDataValidation(ruleIsNaoexiste);
  var executeSetColor = cleanSheet.getConditionalFormatRules();
  executeSetColor.push(ruleSetColor) 
  cleanSheet.setConditionalFormatRules(executeSetColor);  
}

function validationRawSheet(){
  let sheet = SpreadsheetApp.getActiveSpreadsheet();
  let rawSheet = sheet.getSheetByName("Raw");
  let lastRow = rawSheet.getLastRow()-1;
  let colExclude = rawSheet.getRange('A2'+':'+ 'R'+lastRow);
 // let colExcludeValues = colExclude.getValues()
  
  //Destacar as linhas de tags de mídia
  let ruleSetColor = SpreadsheetApp.newConditionalFormatRule()
      .whenFormulaSatisfied("=$I2=false")
      .setBackground('#F5A9BC')
      .setRanges([colExclude])
      .build()
  let executeSetColor = rawSheet.getConditionalFormatRules();
  executeSetColor.push(ruleSetColor) ;
  rawSheet.setConditionalFormatRules(executeSetColor)  
}


