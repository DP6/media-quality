function onInstall(e) {
  onOpen(e);
}

function onOpen(e) {
  createMenu();
}

function createMenu() {
  let ui = SpreadsheetApp.getUi()
    ui.createMenu("Menu de Ações")
    .addSubMenu(ui.createMenu('Dados Brutos')
    .addItem("Acessar todas as tags", "getAllTags")
    .addItem("Selecionar tags de mídia", "getMediaTags"))
    .addSeparator()
    .addSubMenu(ui.createMenu('Dados Limpos')
    .addItem("Validar tags de mídia", "validationCleanSheet")
    .addItem("Criar Workspace e enviar tags para GTM", "sentMediaTags"))
    .addToUi();
}

