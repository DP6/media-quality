/* Create and formats the clean tab  */
function formatClean() {
  console.log("Inicio formatClean")
  let sheet = SpreadsheetApp.getActiveSpreadsheet()
  let cleanSheet = sheet.getSheetByName("Clean");
  cleanSheet.clear();
  
  cleanSheet
    .getRange(1, 1, 1, 12)
    .setValues([["account_id", "container_id", "firing_trigger_id", "workspace_id", "tag_name", "tracking_id", "tag_id","tag_type","exclude", "media_name", "media_event", "parameter"]])
    .setBackground("#007494")
    .setFontColor("#ffffff")
    .setFontWeight("bold");
  console.log("Fim formatClean")
}

/* Check the values in EXCLUDE */
function checkValue() {
  console.log("Inicio checkValue")
  let sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Raw")
  let lastRow = sheet.getLastRow()
  let values = sheet.getRange('I2'+':'+'I'+ lastRow).getValues() 
  let valuesArray = [];
 
  for (let i = 0; i < values.length; i++) {
    if (values[i][0] == false) {
      valuesArray.push(i+2)
    }  
  }
  console.log(valuesArray)
  console.log("Fim checkValue")
  return valuesArray
};


/* get the lines that contain the value */

function getRow(value) {
  console.log("inicio getRow")
  let sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Raw");
  let onlyMediaTags = []

  for (let i = 0; i < value.length; i++) {
  let values = sheet.getRange(value[i], 1, 1, 12).getValues();
    //let values = sheet.getRange(value[i], 1, 1, sheet.getLastColumn()).getValues();
    onlyMediaTags.push(values)
  }
  console.log("fim getRow")
  console.log(onlyMediaTags)
  return { onlyMediaTags }
  
}


/* Insert the lines in the CLEAN tab */

function insertClean(array) {
  console.log("insert clear")

  for (let i = 0; i < array.length; i++) {
    let sheet = SpreadsheetApp.getActive().getSheetByName("Clean");
    let lastRow = sheet.getLastRow();
    let range = sheet.getRange(lastRow + 1, 1, 1, 12);
    range.setValues([...array[i].slice(0, 12)]);
  }
}

