/* Create a new Worlspace */
function createWorkspace(inputData) {
  console.log("Inicio createWorkspace")
  //Acessar dados de entrada 
  let accounts = inputData.account; 
  let containers = inputData.container;

  const date = new Date();
  var timestamp = date.getFullYear() + "-" + (date.getMonth()+1) + "-" + date.getDate() + ", " + date.getHours() + "h" + date.getMinutes() + "m" +   date.getSeconds() + "s";
  
  var container_path = `accounts/${accounts}/containers/${containers}`
  const workspace = TagManager.Accounts.Containers.Workspaces.create(
      {'name': 'Media Quality ' + timestamp, 'description': 'Atualização das tags de mídia'},
      container_path); 
  console.log("Fim createWorkspace")  
  return workspace
}


/* Update and sent all media tags to GTM */
function updateTags(createWorkspace, inputData){
 console.log("Inicio updateTags")
  let sheet = SpreadsheetApp.getActiveSpreadsheet();
  let cleanSheet = sheet.getSheetByName("Clean");
  let tag_name = cleanSheet.getRange('E2:E').getValues();
  let tracking_id	= cleanSheet.getRange('F2:F').getValues();
  let tag_id = cleanSheet.getRange('G2:G').getValues();
  let tag_type = cleanSheet.getRange('H2:H').getValues();
  let exclude	= cleanSheet.getRange('I2:I').getValues();
  let media_name = cleanSheet.getRange('J2:J').getValues();
  let	media_event = cleanSheet.getRange('K2:K').getValues();
  let parameter = cleanSheet.getRange('L2:L').getValues();
  let lastRow = cleanSheet.getLastRow()-1;
  let workspace_id = createWorkspace.workspaceId
  let accounts = inputData.account; 
  let containers = inputData.container; 

  for(let i=0; i<lastRow; i++){ 
   let firing_trigger_id =  (JSON.parse(parameter[i])['firingTriggerId']).toString().replace('.',',').split(",");
   let tag_firing_option = JSON.parse(parameter[i])["tagFiringOption"];
   let parent_folder_id = JSON.parse(parameter[i])["parentFolderId"];
   let paused = JSON.parse(parameter[i])["paused"];
   let setup_tag = JSON.parse(parameter[i])["setupTag"];
   let fingerprint = JSON.parse(parameter[i])["fingerprint"];
   let consent_settings = JSON.parse(parameter[i])["consentSettings"];

   let container_path = `accounts/${accounts}/containers/${containers}/workspaces/${workspace_id}/tags/${tag_id[i][0]}`  
  //let container_path = `accounts/${accounts}/containers/${containers}/workspaces/1000195/tags/${tag_id[i][0]}`

   const tag = TagManager.Accounts.Containers.Workspaces.Tags.update(
        { 
          'name': tag_name[i][0],
          'liveOnly': false,
          'type': tag_type[i][0],
          'parameter': JSON.parse(parameter[i][0])["parameter"],
            'monitoringMetadata':
              {'map':
              [
              {'value': String(exclude[i][0]), 'type':'template','key':'exclude'},
              {'type':'template', 'value': (tracking_id[i][0]).toString(), 'key':'tracking_id'}, 
              {'type':'template','value': media_event[i][0], 'key':'media_event'},
              {'value': media_name[i][0], 'type':'template','key':'media_name'}
              ],
                'type':'map'},           
          'firingTriggerId': firing_trigger_id == ''? null:firing_trigger_id,
          'tagFiringOption':tag_firing_option,
          'monitoringMetadataTagNameKey': 'name',
          'parentFolderId': parent_folder_id,
          'paused': paused == ''? false:paused,
          'setupTag': setup_tag==''? null:setup_tag,
          'fingerprint': String(fingerprint),
          'consentSettings': consent_settings == ''? null:consent_settings
          
        },
        container_path); 
    
  } 
 console.log("Fim updateTags") 

 //Exibir pop-up
  var ui = SpreadsheetApp.getUi();
  var response = ui.alert('Workspace criado: \n' + '\n'+ createWorkspace.name);
  // Process the user's response.
  if (response == ui.Button.YES) {
    Logger.log('The user clicked "Yes."');
  } else {
    Logger.log('The user clicked "No" or the close button in the dialog\'s title bar.');
  } 
}

