___INFO___

{
  "type": "TAG",
  "id": "kukie_cmp",
  "version": 1,
  "securityGroups": [],
  "displayName": "Kukie CMP",
  "categories": ["TAG_MANAGEMENT", "PERSONALIZATION"],
  "brand": {
    "id": "brand_kukie",
    "displayName": "Kukie.io"
  },
  "description": "Consent management template for Kukie.io CMP. Sets Google Consent Mode v2 defaults and updates consent state based on user choices. Supports all 7 consent parameters with per-region defaults, ads data redaction, and URL passthrough.",
  "containerContexts": ["WEB"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "siteKey",
    "displayName": "Kukie Site Key",
    "simpleValueType": true,
    "help": "Your site key from the Kukie dashboard (UUID format). Find it in Sites \u003e Overview \u003e Embed Code.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "scriptUrl",
    "displayName": "Script URL (optional)",
    "simpleValueType": true,
    "help": "Leave blank to use CDN bundle (recommended). Only fill in if using a custom script URL.",
    "defaultValue": ""
  },
  {
    "type": "PARAM_TABLE",
    "name": "defaultSettings",
    "displayName": "Default Consent Settings",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "region",
          "displayName": "Region (leave blank for all regions)",
          "simpleValueType": true
        },
        "isUnique": true
      },
      {
        "param": {
          "type": "TEXT",
          "name": "granted",
          "displayName": "Granted Consent Types (comma-separated)",
          "simpleValueType": true
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "denied",
          "displayName": "Denied Consent Types (comma-separated)",
          "simpleValueType": true
        },
        "isUnique": false
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "ads_data_redaction",
    "checkboxText": "Redact Ads Data",
    "simpleValueType": true,
    "defaultValue": false,
    "help": "When enabled, ad click identifiers sent in network requests by Google Ads and Floodlight tags will be redacted when ad_storage consent is denied."
  },
  {
    "type": "CHECKBOX",
    "name": "url_passthrough",
    "checkboxText": "Pass through URL parameters",
    "simpleValueType": true,
    "defaultValue": true,
    "help": "Recommended. Preserves ad click information across pages when cookies are denied by appending link parameters."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const gtagSet = require('gtagSet');
const injectScript = require('injectScript');
const setInWindow = require('setInWindow');
const makeString = require('makeString');

const DEVELOPER_ID = 'dOTA0OT';

/**
 * Split a comma-separated string into a trimmed array.
 */
const splitInput = function(input) {
  if (!input) return [];
  const parts = input.split(',');
  const result = [];
  for (let i = 0; i < parts.length; i++) {
    const trimmed = parts[i].trim();
    if (trimmed.length > 0) {
      result.push(trimmed);
    }
  }
  return result;
};

/**
 * Parse a default-settings row into a setDefaultConsentState argument.
 */
const parseCommandData = function(settings) {
  const regions = splitInput(settings.region);
  const granted = splitInput(settings.granted);
  const denied = splitInput(settings.denied);
  const commandData = {};

  if (regions.length > 0) {
    commandData.region = regions;
  }
  for (let i = 0; i < granted.length; i++) {
    commandData[granted[i]] = 'granted';
  }
  for (let i = 0; i < denied.length; i++) {
    commandData[denied[i]] = 'denied';
  }
  return commandData;
};

/**
 * Map Kukie cookie-category slugs to Google Consent Mode consent types.
 *
 * Categories: necessary, analytics, marketing, functional
 * GCM types:  ad_storage, ad_user_data, ad_personalization,
 *             analytics_storage, functionality_storage,
 *             personalization_storage, security_storage
 */
const mapCategoriesToConsent = function(categories) {
  const has = function(cat) {
    return categories.indexOf(cat) !== -1;
  };

  return {
    ad_storage: has('marketing') ? 'granted' : 'denied',
    ad_user_data: has('marketing') ? 'granted' : 'denied',
    ad_personalization: has('marketing') ? 'granted' : 'denied',
    analytics_storage: has('analytics') ? 'granted' : 'denied',
    functionality_storage: has('functional') ? 'granted' : 'denied',
    personalization_storage: has('functional') ? 'granted' : 'denied',
    security_storage: 'granted'
  };
};

// ---------------------------------------------------------------------------
// 1. Developer ID
// ---------------------------------------------------------------------------
gtagSet('developer_id.' + DEVELOPER_ID, true);

// ---------------------------------------------------------------------------
// 2. Optional features
// ---------------------------------------------------------------------------
if (data.ads_data_redaction) {
  gtagSet('ads_data_redaction', true);
}
if (data.url_passthrough) {
  gtagSet('url_passthrough', true);
}

// ---------------------------------------------------------------------------
// 3. Default consent state (from template UI configuration)
// ---------------------------------------------------------------------------
if (data.defaultSettings) {
  for (let i = 0; i < data.defaultSettings.length; i++) {
    const commandData = parseCommandData(data.defaultSettings[i]);
    commandData.wait_for_update = 500;
    setDefaultConsentState(commandData);
  }
}

// ---------------------------------------------------------------------------
// 4. Register callback for consent updates from Kukie banner script
//
//    The Kukie banner calls window.__kukie_gtm_consent_callback(categories)
//    every time consent changes (initial restore from cookie, user interaction,
//    opt-out, notice-only accept). This lets the GTM template call
//    updateConsentState() with the correct mapping.
//
//    Note: The banner also calls gtag('consent', 'update', ...) directly,
//    which flows through dataLayer. Both paths set the same values.
// ---------------------------------------------------------------------------
setInWindow('__kukie_gtm_consent_callback', function(categories) {
  updateConsentState(mapCategoriesToConsent(categories));
}, false);

// ---------------------------------------------------------------------------
// 5. Inject Kukie banner script
// ---------------------------------------------------------------------------
const siteKey = makeString(data.siteKey || '');

if (siteKey) {
  const scriptUrl = data.scriptUrl ||
    ('https://cdn.kukie.io/s/' + siteKey + '/c.js');

  injectScript(scriptUrl, function() {
    log('Kukie CMP: Script loaded');
  }, function() {
    log('Kukie CMP: Failed to load script');
  }, 'kukieCmp');
}

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "vpiId": "access_consent"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ad_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ad_user_data" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "ad_personalization" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "analytics_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "functionality_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "personalization_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "consentType" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" }
                ],
                "mapValue": [
                  { "type": 1, "string": "security_storage" },
                  { "type": 8, "boolean": false },
                  { "type": 8, "boolean": true }
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
        "publicId": "inject_script",
        "vpiId": "inject_script"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://cdn.kukie.io/*"
              },
              {
                "type": 1,
                "string": "https://app.kukie.io/*"
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
        "publicId": "access_globals",
        "vpiId": "access_globals"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  { "type": 1, "string": "key" },
                  { "type": 1, "string": "read" },
                  { "type": 1, "string": "write" },
                  { "type": 1, "string": "execute" }
                ],
                "mapValue": [
                  { "type": 1, "string": "__kukie_gtm_consent_callback" },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": true },
                  { "type": 8, "boolean": false }
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
        "vpiId": "logging"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
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
        "publicId": "write_data_layer",
        "vpiId": "write_data_layer"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "developer_id.*"
              },
              {
                "type": 1,
                "string": "ads_data_redaction"
              },
              {
                "type": 1,
                "string": "url_passthrough"
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
