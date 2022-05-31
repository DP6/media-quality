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
  "description": "Coleta via Cloud Function e GA4",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "CHECKBOX",
    "name": "autoCollect",
    "checkboxText": "Disable automatic parameter identification",
    "simpleValueType": true,
    "help": "It must pass the parameters that receive the media name and the media event (Check the documentation for more details)"
  },
  {
    "type": "TEXT",
    "name": "clientId",
    "displayName": "Client ID",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "It must pass the variable that receives the Google Analytics client id"
  },
  {
    "type": "TEXT",
    "name": "sample",
    "displayName": "Sampling",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Define the percentage of users that will be monitored",
    "valueValidators": [
      {
        "type": "PERCENTAGE"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "domain",
    "displayName": "Domain",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Domain to be monitored"
  },
  {
    "type": "SELECT",
    "name": "typeEndpoint",
    "displayName": "Collection mode",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "cf",
        "displayValue": "Cloud Function"
      },
      {
        "value": "ga4",
        "displayValue": "GA4"
      }
    ],
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "To use all modules of the solution, it is recommended to use the Cloud Function method. With the GA4 method, it is possible to use only module 1 (Check the documentation for more details)",
    "alwaysInSummary": true
  },
  {
    "type": "TEXT",
    "name": "cfEndpoint",
    "displayName": "Endpoint",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^https:\\/\\/.+cloudfunctions.+"
        ]
      }
    ],
    "help": "Add the Cloud Function destination URL",
    "enablingConditions": [
      {
        "paramName": "typeEndpoint",
        "paramValue": "cf",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "measurementId",
    "displayName": "Measurement ID",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^G-.*"
        ]
      }
    ],
    "help": "Add the Measurement ID of the GA4",
    "enablingConditions": [
      {
        "paramName": "typeEndpoint",
        "paramValue": "ga4",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "apiSecret",
    "displayName": "API Secret",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "enablingConditions": [
      {
        "paramName": "typeEndpoint",
        "paramValue": "ga4",
        "type": "EQUALS"
      }
    ],
    "help": "The solution uses the GA4 Measurement Protocol. To create an API secret, go to \"Admin \u003e Data Streams \u003e choose your stream \u003e Measurement Protocol\""
  },
  {
    "type": "TEXT",
    "name": "sendBeacon",
    "displayName": "Send Beacon Reference",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Add the Custom Javascript which has sendBeacon function (Check the documentation for more details)",
    "enablingConditions": [
      {
        "paramName": "typeEndpoint",
        "paramValue": "ga4",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "method",
    "displayName": "Request Method",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "get",
        "displayValue": "GET"
      },
      {
        "value": "post",
        "displayValue": "POST"
      }
    ],
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "typeEndpoint",
        "paramValue": "cf",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "fetchReference",
    "displayName": "Fetch Reference",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Add the Custom Javascript which has fetch function (Check the documentation for more details)",
    "enablingConditions": [
      {
        "paramName": "method",
        "paramValue": "post",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "addParams",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "params",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Parameter",
            "name": "param",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT"
          }
        ],
        "alwaysInSummary": true
      }
    ],
    "displayName": "Additional parameters"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

//Importing the necessary APIs
const log = require('logToConsole');
const getContainerVersion = require('getContainerVersion');
const addEventCallback = require('addEventCallback');
const readFromDataLayer = require('copyFromDataLayer');
const sendPixel = require('sendPixel');
const random = require('generateRandom');
const getCookieValues = require('getCookieValues');
const setCookie = require('setCookie');
const JSON = require('JSON');
const encodeUri = require('encodeUri');
const container = getContainerVersion();


//Creates the cookie if it doesn't exist and indicates if the user will be monitored
let domain = data.domain ? data.domain : 'auto';
if (!getCookieValues('media_quality')[0]) {
    if (random(0, 100) <= data.sample) 
        setCookie('media_quality', 'true', {'maxAge': 36000, 'domain': domain});
    else 
        setCookie('media_quality', 'false', {'maxAge': 36000, 'domain': domain});
}

//If user should be monitored, choose the endpoint
if (getCookieValues('media_quality')[0] === 'true') {
    if (data.typeEndpoint == 'ga4') sendToGa4();
    else if (data.typeEndpoint == 'cf') sendToCF(data.method);
}
data.gtmOnSuccess();

function sendToGa4() {

    const event = readFromDataLayer('event');
    const sendBeacon = data.sendBeacon;
    const endpoint = 'https://www.google-analytics.com/mp/collect?measurement_id=' +  data.measurementId +'&api_secret=' + data.apiSecret;

    addEventCallback(function(containerId, eventData) {
        let body = {
            client_id: data.clientId,
            events: []
        };

        const tagData = eventData.tags.filter(t => t.exclude === 'false');
        
        for (let i in tagData) {

          let entry = tagData[i];
          let params = {
              debug_mode: container.debugMode,
              media_name: data.autoCollect ? entry.media_name : entry.name.split(' - ')[0].split(' (')[0],
              tracking_id: entry.tracking_id,
              media_event: data.autoCollect ? entry.media_event : entry.name.split(' - ')[1],
              tag_name: entry.name,
              status: entry.status,
              datalayer_event: event
          };
          for (let j in data.params) {
            let name = data.params[j].param;
            let value = data.params[j].value;
            params[name] = value;
          }
          body.events.push({name: 'media_quality', params: params});
          
      }
      if(body.events.length > 0)
        sendBeacon(endpoint, JSON.stringify(body));
    });
}

function sendToCF(method) {

    const endpoint = data.cfEndpoint;
    const event = readFromDataLayer('event');
    const fetch = data.fetchReference;

    addEventCallback(function(containerId, eventData) {
        
        const tagData = eventData.tags.filter(t => t.exclude === 'false');
        for (let i in tagData) {

            let entry = tagData[i];
            let body = {
                client_id: data.clientId,
                media_name: data.autoCollect ? entry.media_name : entry.name.split(' - ')[0].split(' (')[0],
                tracking_id: entry.tracking_id,
                media_event: data.autoCollect ? entry.media_event : entry.name.split(' - ')[1],
                tag_name: entry.name,
                status: entry.status,
                datalayer_event: event
            };
            for (let j in data.params) {
                let name = data.params[j].param;
                let value = data.params[j].value;
                body[name] = value;
            }
            
            //Send data via GET method
            if (method == 'get') {
                var url = "";
                for (let item in body) {
                    url += '&' + item + '=' + body[item];
                }
                url = endpoint+ "/?" + encodeUri(url);
                sendPixel(url,null,null);
            }
            //Send data via POST method
            else if (method == 'post') {
                fetch(endpoint, body);
            }
        }
    });
}


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
            "string": "any"
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
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
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
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 20/04/2022 18:40:00


