function formatRaw() {
  console.log("Inicio formatRaw")
  let sheet = SpreadsheetApp.getActiveSpreadsheet()
  let rawSheet = sheet.getSheetByName("Raw");
  rawSheet.clear();
  rawSheet
    .getRange(1, 1, 1, 12)
    .setValues([["account_id", "container_id", "firing_trigger_id", "workspace_id", "tag_name", "tracking_id", "tag_id","tag_type","exclude", "media_name", "media_event", "parameter"]])
    .setBackground("#007494")
    .setFontColor("#ffffff")
    .setFontWeight("bold");
  console.log("Fim formatRaw")
}

function accessGTM(inputData) {
  console.log("Inicio accessGTM") 
 //Acessar dados de entrada 
  let accounts = inputData.account; 
  let containers = inputData.container; 
  let workspaces = inputData.workspace;

 //Acessar o container e listar as tags  
  let version_path = `accounts/${accounts}/containers/${containers}/workspaces/${workspaces}`
  try{ 
    var list_tags = TagManager.Accounts.Containers.Workspaces.Tags.list(version_path).tag;
  }catch(err){
    throw new Error('Invalid input data: Check account, container and workspace data')
  } 
  var tracking_id = '';
  var reduced_tags = [];
  var tracking_id_list = [];
  var exclude_list = [];
  var media_name_list = [];
  var media_event_list = [];
  
  //tracking_id
  //Percorrer as tags e verificar se o tracking_id existe, e se não houver, vamos setar como "Não existe"
  for (var i=0 ; i < list_tags.length; i++ ){
    var tag_monitoringMetadata = (list_tags[i].monitoringMetadata);
    //Tracking_id
    if(tag_monitoringMetadata == undefined || tag_monitoringMetadata.map == undefined){        
        tracking_id = undefined
    }else{    
      tracking_id = tag_monitoringMetadata.map.find(({ key }) => {      
      return key === "tracking_id"                 
      });    
    }   

    if(tracking_id == undefined){
      tracking_id_list.push('Não existe');
    }else{
    tracking_id_list.push(tracking_id.value);
    }

    //exclude
    if(tag_monitoringMetadata == undefined || tag_monitoringMetadata.map == undefined){        
        exclude = undefined
    }else{    
      exclude = tag_monitoringMetadata.map.find(({ key }) => {      
      return key === "exclude"                 
      });    
    } 
      if(exclude == undefined){
      exclude_list.push(true); //true 
    }else{
      exclude_list.push(exclude.value); //false
    }

    //media_name
    if(tag_monitoringMetadata == undefined || tag_monitoringMetadata.map == undefined){        
        media_name = undefined
    }else{    
      media_name = tag_monitoringMetadata.map.find(({ key }) => {      
      return key === "media_name"                 
      });    
    }  
    if(media_name == undefined){
      media_name_list.push('Não existe');
    }else{
    media_name_list.push(media_name.value);
    }

    //media_event
    if(tag_monitoringMetadata == undefined || tag_monitoringMetadata.map == undefined){        
        media_event = undefined
    }else{    
      media_event = tag_monitoringMetadata.map.find(({ key }) => {      
      return key === "media_event"                 
      });    
    }  
    if(media_event == undefined){
      media_event_list.push('Não existe');
    }else{
    media_event_list.push(media_event.value);
    }


    //Tratar as tags 
      var reduced_array = [
                           list_tags[i].accountId,
                           list_tags[i].containerId,
                           [list_tags[i].firingTriggerId].toString(),
                           list_tags[i].workspaceId,
                           list_tags[i].name,
                           tracking_id_list[i],
                           list_tags[i].tagId,
                           list_tags[i].type,
                           exclude_list[i],  
                           media_name_list[i],
                           media_event_list[i],
                           JSON.stringify(list_tags[i])                                                     
                          ]           
      reduced_tags.push(reduced_array)  

  //Inserir dados das tags na planilha
  let sheet = SpreadsheetApp.getActiveSpreadsheet()
  let rawSheet = sheet.getSheetByName("Raw");
  let length_list = String(reduced_tags.length + 1);
  rawSheet.getRange('A2'+':'+'L'+ length_list).setValues(reduced_tags);

  //Inserir o checkbox na coluna Exclude 
  let excludeRule = SpreadsheetApp.newDataValidation().requireCheckbox().build();  
  let colExclude = rawSheet.getRange('I2'+':'+'I'+ length_list);
  colExclude.setDataValidation(excludeRule);  
  }

console.log("Fim accessGTM")
}




