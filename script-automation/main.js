function getAllTags() {
  formatRaw();
  let input = inputData();
  accessGTM(input);
  validationRawSheet()
}

function getMediaTags() {
  formatClean();
  let get = getRow(checkValue())
  insertClean(get.onlyMediaTags)  
}

function sentMediaTags(){
  let input = inputData();
  let workspaceId = createWorkspace(input)
  updateTags(workspaceId,input)
}
