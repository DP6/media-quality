___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Media Quality",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "uaCode",
    "displayName": "Property ID",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "GA_TRACKING_ID"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "sample",
    "displayName": "Amostragem",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Definir a porcentagem de usuários que serão contabilizados no Media Quality",
    "valueValidators": [
      {
        "type": "PERCENTAGE"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "domain",
    "displayName": "Domínio (Cookie)",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Domínio do cookie de usuário"
  },
  {
    "type": "GROUP",
    "name": "addParams",
    "displayName": "Parâmetros adicionais",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "params",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Parâmetros",
            "name": "param",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Valor",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "alwaysInSummary": true
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

//Importando as APIs necessárias
const addEventCallback = require('addEventCallback');
const readFromDataLayer = require('copyFromDataLayer');
const sendPixel = require('sendPixel');
const random = require('generateRandom');
const getCookieValues = require('getCookieValues');
const setCookie = require('setCookie');

//Lendo o dado de evento da dataLayer
const event = readFromDataLayer('event');

//Cria o cookie caso não exista e altera o valor caso entre no sorteio
let domain = data.domain ? data.domain : 'auto';
if (!getCookieValues('media_quality')[0]) {
  if (random(0, 100) <= data.sample)
    setCookie('media_quality', 'true', {'maxAge': 36000, 'domain': domain});
  else
    setCookie('media_quality', 'false', {'maxAge': 36000, 'domain': domain});
}

//Executa o Media Quality caso o valor do cookie seja true
if (getCookieValues('media_quality')[0] === 'true') {
  
  addEventCallback(function(containerId, eventData) {
    const tagData = eventData.tags.filter(t => t.exclude === 'false');
    let countTags = 0;
    for (let i in tagData) {
      let url = 'https://www.google-analytics.com/collect?' +
      'v=1' +
      '&t=event' +
      '&tid=' + data.uaCode +
      '&cid=' + getCookieValues('_ga')[0]
      ;

      let entry = tagData[i];
      url += '&ec=' + entry.name.split(' - ')[0].split(' (')[0];
      url += '&ea=' + entry.pixel_tracking_id;
      url += '&el=' + entry.name.split(' - ')[1];
      url += '&cd1=' + entry.status;
      url += '&cd2=' + entry.name;
      url += '&cd3=' + event;
      
      //Parâmetros adicionais
      for (let j in data.params) {
        url += '&' + data.params[j].param + '=' + data.params[j].value;
      }
      
      countTags++;
      if (countTags > 0) {
        sendPixel(url, null, null);
      }
    }
  });
}
data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_metadata",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "event"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.google-analytics.com/collect*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "media_quality"
              },
              {
                "type": 1,
                "string": "_ga"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "media_quality"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 17/03/2022 14:09:33


