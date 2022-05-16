# Configuração com o uso da Cloud Function

Para enviar os dados dos eventos para o Big Query utilizando Cloud Functions é necessário realizar os passos a seguir:

- Criação de dataset e tabela no Big Query;
- Criação de Cloud Function;
- Adequação do custom template para envio de requisições para a Cloud Function.

## Criação de dataset e tabela no Big Query

Para criar a tabela acesse o GCP (Google Cloud Plataform) e crie um dataset com o nome `mediaQualityDataset` e uma tabela com o nome `raw_data`.

As colunas criadas na tabela são:

| Nome da Coluna  | Descrição                                     |
| --------------- | --------------------------------------------- |
| media_name      | Nome da mídia que foi disparada               |
| tracking_id     | Id de acompanhamento da mídia disparada       |
| media_event     | Nome do evento disparado                      |
| tag_name        | Nome completo da tag disparada no GTM         |
| status          | Status de disparo da tag                      |
| datalayer_event | Nome do evento do DataLayer que acionou a tag |
| timestamp       | Data e hora do registro                       |

Ao criar a tabela selecione a opção para realizar o particionamento diário dos dados utilizando a coluna `timestamp`. O código abaixo contém um JSON com o esquema da tabela criada.

```javascript
// Esquema da tabela criada no Big Query
[
  {
    description: 'Nome da m\u00eddia que foi disparada',
    maxLength: '100',
    mode: 'NULLABLE',
    name: 'media_name',
    type: 'STRING',
  },
  {
    description: 'Id de acompanhamento da m\u00eddia disparada',
    mode: 'NULLABLE',
    name: 'tracking_id',
    type: 'INTEGER',
  },
  {
    description: 'Nome do evento disparado',
    maxLength: '100',
    mode: 'NULLABLE',
    name: 'media_event',
    type: 'STRING',
  },
  {
    description: 'Nome completo da tag disparada no GTM',
    maxLength: '100',
    mode: 'NULLABLE',
    name: 'tag_name',
    type: 'STRING',
  },
  {
    description: 'Status de disparo da tag',
    maxLength: '50',
    mode: 'NULLABLE',
    name: 'status',
    type: 'STRING',
  },
  {
    description: 'Nome do evento do DataLayer que acionou a tag',
    maxLength: '100',
    mode: 'NULLABLE',
    name: 'datalayer_event',
    type: 'STRING',
  },
  {
    description: 'Data e hora do registro',
    mode: 'REQUIRED',
    name: 'timestamp',
    type: 'TIMESTAMP',
  },
];
```

## Criação de Cloud Function

Para criar a Cloud Function acesse o [GCP](https://console.cloud.google.com/functions) (Google Cloud Plataform) e utilize código diponibilizado abaixo. Foram utilizados `Runtime: Node.js 16` e `Entry point: gtm_monitor`. É importante verificar se a Cloud Function está acessível, portanto, verifique a secção `Permissions` para habilitar as permissões necessárias. Para a criação da function foram usados os arquivos `index.js` e `package.json`.

A function recebe uma requisição HTTP que pode conter dados em JSON ou uma URL com query params. Para selecionar uma das opções é preciso alterar o valor da constante `input_option` localidada nas primeiras linhas de código.

Os dados em formato JSON recebidos pela function estão no seguinte formato:
``` javascript
{
    "media_name": "media_name",
    "tracking_id": 123,
    "media_event": "media_event",
    "tag_name": "tag_name",
    "status": "status",
    "datalayer_event": "datalayer_event",
    "timestamp": 1652359111.576
}
```

Caso os dados recebidos pelo Cloud Function seja uma URL ela será do seguinte formato:
```
https://{{URL da Cloud Function}}/?media_name={{media_name}}&tracking_id={{tracking_id}}&media_event={{media_event}} ...
```
As informações provenientes da URL são organizadas em um dicionário após a extração por meio de expressões regulares. Posteriormente os dados são enviados para o Big Query.


**index.js**
``` javascript
// Import the Google Cloud client library
const {BigQuery} = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

// Select what kind of data req.body contains. If the data 
// comes from sendPixel method (used on GTM custom template) use "url" else use "json"
const input_option = 'json'; // url ou json

async function insertRowsAsStream(request, input_option) {

    const datasetId = 'mediaQualityDataset';
    const tableId = 'raw_data';
    var json_data; 

    if (input_option == "url"){
      const url = decodeURI(request.protocol + '://' + request.get('host') + request.originalUrl);
 
      json_data = {
        media_name: url.match("media_name=([^&]+)")[1],
        tracking_id: url.match("tracking_id=([^&]+)")[1],
        media_event: url.match("media_event=([^&]+)")[1],
        tag_name: url.match("tag_name=([^&]+)")[1],
        status: url.match("status=([^&]+)")[1],
        datalayer_event: url.match("datalayer_event=([^&]+)")[1],
        timestamp: Date.now() / 1000
      };
    }

    if (input_option == "json"){
      try {
        // Parse a JSON
        json_data = JSON.parse(request.body); 
      } catch (e) {
        json_data = request.body;
      }

      json_data["timestamp"] = Date.now() /1000;

    }
    
    
    console.log("Enviando payload: ", json_data);
    // Insert data into a table
    await bigquery
      .dataset(datasetId)
      .table(tableId)
      .insert(json_data);
    console.log(`Inserted rows`);
  }

exports.gtm_monitor = (req, res) =>{
    
    if(req.body){
      insertRowsAsStream(req, input_option);
      console.log("Processo finalizado...");
      res.sendStatus(200);
    } else
    {
        console.log("Requisição inválida");
    }
};
```
**package.json**
``` javascript
{
    "name": "send-from-gtm-2-bq",
    "version": "1.0.0",
    "description": "envia dados para o bigquery atraves de cloud function",
    "author": "dp6",
    "dependencies": {
      "@google-cloud/bigquery": "^2.1.0"
    },
    "license": "ISC"
  }
```



## Adequação do custom template para envio de requisições para a Cloud Function

Existem duas maneiras de enviar os dados para a Cloud Function, uma utilizando o método `sendPixel` e a outra utizando `Fetch`.

### Opção 1: sendPixel

O sendPixel é utilizado para realizar requisições do tipo GET. Ela recebe como parâmetro uma URL que é composta por `URL = endpoint + query params`. O endpoint é a URL da Cloud Function enquanto que os query params contém os dados de mídia que serão enviados para a Cloud Function.

### Opção 2: Fetch

O `fetch` permite realizar requisições do tipo POST e o envio de dados no formato JSON. No GTM deve-se criar uma variável do tipo custom javascript e inserir a função responsável pela requisição. Na tag do GTM o campo `sendFetchReference` deve ser preenchido com a variável criada. 


**Código javascript utilizado no template de Media Quality (GTM)**
``` javascript
...

const encodeUri = require('encodeUri');
const sendPixel = require('sendPixel');
const sendRequestFetch = data.sendFetchReference;
const requestSecret = data.requestSecret;

...        
function fetchToCF(method) {
  // URL da cloud function
  const endpoint = data.cfEndpoint;
  
  addEventCallback(function(containerId, eventData) {
    
    const tagData = eventData.tags.filter(t => t.exclude === 'false');
    
    for (let i in tagData) {
      
      let entry = tagData[i];
      
      let midia_params = {
            media_name: entry.name.split(' - ')[0].split(' (')[0],
            tracking_id: entry.tracking_id,
            media_event: entry.name.split(' - ')[1],
            tag_name: entry.name,
            status: entry.status,
            datalayer_event: event
        };
      
      
      if(method =='sendpixel'){
        // Montagem da URL da requisição
        var url = "";
      
        for (let item in midia_params) {
        url += '&' + item + '=' + midia_params[item];
        }

        url = endpoint+ "/?" + encodeUri(url);
        // Envia requisição utilizando sendPixel 
        sendPixel(url,null,null);
        
      } 
      
      if(method == 'fetch'){
        // Envia requisição utilizando fetch
        sendRequestFetch(endpoint, midia_params, requestSecret);
         
      }
    }
  });
}

...
```



**Função Fetch (utilizada na custom javascript variable do GTM)**

``` javascript
function(){
  function CustomFetch(endpoint, payload, secret){ 
    fetch(endpoint, {
    method: "POST",
    mode: 'no-cors',
    body: JSON.stringify(payload),
    headers: {'Content-Type': 'application/json', 'Authorization': secret}
    });    
  }
  return CustomFetch;
}
```



## Imagens da Implementação

### Passo 1: Criação da variável javascript
Criação de variável javascript com o código responsável pelas requisições HTTP. Caso seja utilizada a outra forma de envio de dados (sendPixel) não é necessário criar essa variável.
<div align="center">
<img src="./documentation-images/custom-javascript-fetch.png" height="auto" />
<figcaption>Figura 1 - Criação de custom javascript com a função fetch.</figcaption>
</div>



Após habilitar na tag o "Endpoint de destino" como Cloud Function deve-se inserir a URL de trigger da Cloud Function, a variável javascript criada anteriormente e um segredo a ser adicionado na requisição HTTP (ainda em desenvolvimento), conforme o exemplo abaixo (Figura 2).

<div align="center">
<img src="./documentation-images/tag-configuration-2.png" height="auto" />
<figcaption>Figura 2 - Preenchimento do campo Endpoint com URL da Cloud Function</figcaption>
</div>





