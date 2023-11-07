
function onOpen(){
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  let rawSheet = sheet.getSheetByName("Raw");
  let cleanSheet = sheet.getSheetByName("Clean");
  var rawProtection = rawSheet.protect().setWarningOnly(true);
  var cleanProtection = cleanSheet.protect().setWarningOnly(true);
  var rawUnprotected = rawSheet.getRange('I2:I');
  var trackingIdUnprotected = cleanSheet.getRange('F2:F');
  var mediaNameUnprotected = cleanSheet.getRange('J2:J');
  var mediaEventUnprotected = cleanSheet.getRange('K2:K');
  rawProtection.setUnprotectedRanges([rawUnprotected]);
  cleanProtection.setUnprotectedRanges([trackingIdUnprotected,mediaNameUnprotected,mediaEventUnprotected]);
}






