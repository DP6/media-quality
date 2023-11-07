/*** Adicionar valores de entrada contidas na aba Dados de Entrada
 */
function inputData(){
  let sheet = SpreadsheetApp.getActiveSpreadsheet();
  let inputDataSheetPt = sheet.getSheetByName("Input PT").getRange('E2:E4').getValues().flat()
  let inputDataSheetEn = sheet.getSheetByName("Input EN").getRange('E2:E4').getValues().flat()
  let inputData = ''

  if (inputDataSheetPt.includes('') != true){
    inputData = inputDataSheetPt
  } else if(inputDataSheetEn.includes('') != true){
    inputData = inputDataSheetEn
  } 

  let DATA = {
  'account' : (inputData[0]),
  'container' : (inputData[1]),
  'workspace' : (inputData[2])
  }
  return (DATA)
}

