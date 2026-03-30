# Kukie CMP - Google Tag Manager Template

Google Consent Mode v2 integration template for [Kukie.io](https://kukie.io) consent management platform.

## Features

- Sets all 7 Google Consent Mode v2 parameters
- Per-region default consent settings
- Automatic consent updates from Kukie banner
- Ads data redaction support
- URL passthrough for ad click attribution
- Works with CDN bundles and legacy embed

## Setup

1. In GTM, go to Tags > New > Tag Configuration
2. Search for "Kukie CMP" in the Community Template Gallery
3. Enter your Kukie Site Key (found in your Kukie dashboard under Sites > Overview)
4. Configure default consent settings:
   - For EU/EEA: set all consent types to "denied"
   - For other regions: adjust as needed
5. Set trigger to "Consent Initialization - All Pages"
6. Save and publish

## Default Settings Example

| Region | Granted | Denied |
|--------|---------|--------|
| (blank - all regions) | | ad_storage, ad_user_data, ad_personalization, analytics_storage, functionality_storage, personalization_storage |

For opt-out regions (e.g. US), add a second row:

| Region | Granted | Denied |
|--------|---------|--------|
| US | ad_storage, ad_user_data, ad_personalization, analytics_storage, functionality_storage, personalization_storage | |

## Documentation

- [Google Consent Mode v2: Basic vs Advanced](https://kukie.io/docs/integrations/google-consent-mode-basic-vs-advanced)
- [Google's Banner Requirements](https://kukie.io/docs/integrations/google-banner-requirements)
- [Kukie Help Centre](https://kukie.io/docs)

## Support

- [Kukie Support](mailto:support@kukie.io)
- [GitHub Issues](https://github.com/FileSubmit/kukie-gtm-template/issues)

## License

Apache 2.0
