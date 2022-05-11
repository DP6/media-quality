<div align="center">
<img src="https://raw.githubusercontent.com/DP6/templates-centro-de-inovacoes/main/public/images/centro_de_inovacao_dp6.png" height="100px" />
</div>

# Configuração com o uso da Cloud Function

Para enviar os dados dos eventos para o Big Query utilizando Cloud Functions é necessário realizar os passos a seguir:

- Criação de dataset e tabela no Big Query;
- Criação de Cloud Function;
- Adequação do custom template para envio de requisições para a Cloud Function.

Após habilitar na tag o "Endpoint de destino" como Cloud Function deve-se inserir a URL conforme a imagem abaixo (Figura 1).

<div align="center">
<img src="./images/tag-config.png" height="auto" />
<figcaption>Figura 1 - Preenchimento do campo Endpoint com URL da Cloud Function</figcaption>
</div>

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

Para criar a Cloud Function acesse o [GCP](https://console.cloud.google.com/functions) (Google Cloud Plataform) e utilize código diponibilizado abaixo. Forams utilizados `Runtime: Node.js 16` e `Entry point: gtm_monitor`. É importante verificar se a cloud function está acessível, portanto, verifique a secção `Permissions` para habilitar as permissões necessárias. Para a criação da function foram usados os arquivos `index.js` e `package.json`.

A function recebe uma requisição HTTP e extrai a URL no seguinte formato:

```
https://{{URL da Cloud Function}}/?media_name={{media_name}}&tracking_id={{tracking_id}}&media_event={{media_event}} ...
```

As informações provenientes da URL são organizadas em um dicionário após a extração por meio de expressões regulares. Posteriormente os dados são enviados para o Big Query.

**index.js**

```javascript
// Cloud function responsável por enviar dados para o Bigquery

const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

async function insertRowsAsStream(url_encoded) {
  const datasetId = 'mediaQualityDataset'; // Nome do dataset (alterar se necessário)
  const tableId = 'raw_data'; // Nome da tabela (alterar se necessário)

  const url = decodeURI(url_encoded);

  const json_data = {
    media_name: url.match('media_name=([^&]+)')[1],
    tracking_id: url.match('tracking_id=([^&]+)')[1],
    media_event: url.match('media_event=([^&]+)')[1],
    tag_name: url.match('tag_name=([^&]+)')[1],
    status: url.match('status=([^&]+)')[1],
    datalayer_event: url.match('datalayer_event=([^&]+)')[1],
    timestamp: Date.now() / 1000,
  };

  console.log('Enviando payload: ', json_data);

  await bigquery.dataset(datasetId).table(tableId).insert(json_data);
  console.log(`Inserted rows`);
}

exports.gtm_monitor = (req, res) => {
  if (req.body) {
    insertRowsAsStream(req.protocol + '://' + req.get('host') + req.originalUrl);
    console.log('Processo finalizado...');
    res.sendStatus(200);
  } else {
    console.log('Requisição inválida');
  }
};
```

**package.json**

```javascript
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

Foi adicionado no custom template uma função responsável por enviar os dados dos eventos para a Cloud Function. Uma URL é gerada contendo os compomentes `URL = endpoint + query params`. O endpoint é a URL da Cloud Function enquanto que os query params contém os dados de mídia que serão enviados para a Cloud Function.

```javascript
...

const encodeUri = require('encodeUri');
const sendPixel = require('sendPixel');

...
// Função responsável por enviar dados para a cloud function

function fetchToCF() {
  // URL da cloud function
  const endpoint = data.cfEndpoint;

  addEventCallback(function(containerId, eventData) {

    const tagData = eventData.tags.filter(t => t.exclude === 'false');
    let countTags = 0;

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

      var url = "";

      for (let item in midia_params) {
        url += '&' + item + '=' + midia_params[item];
      }
      // Montagem da URL da requisição
      url = endpoint+ "/?" + encodeUri(url);
      // Requisição HTTP
      sendPixel(url,null,null);
    }
  });
}

...
```
