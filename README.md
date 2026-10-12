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
3. Enter your Kukie Site Key (in your Kukie dashboard: your site's Overview, Installation card, Google Tag Manager tab)
4. Configure default consent settings:
   - Add a row with the region left blank and all six types as denied (see below)
   - If you add no rows, the tag denies all six and grants security_storage
5. Set trigger to "Consent Initialization - All Pages"
6. Save and publish

The tag reports success once the Kukie banner script has loaded. If the browser refuses the script, Tag Assistant shows the tag as failed and the console (in Preview mode) says why.

## Content Security Policy

If your site sends a `Content-Security-Policy` header or meta tag, it must allow the banner, or the browser refuses the script this tag adds:

| Directive | Add |
|-----------|-----|
| `script-src` | `https://cdn.kukie.io` |
| `style-src` | `'unsafe-inline'` (in a new `style-src-elem` if your `style-src` lists a hash or a nonce) |
| `connect-src` | `https://app.kukie.io` |

Details: [Allow Kukie.io in your Content Security Policy](https://kukie.io/docs/installation-guides/content-security-policy). The Installation card's **Verify installation** in the Kukie dashboard lists the exact changes your policy needs.

## Default Settings Example

| Region | Granted | Denied |
|--------|---------|--------|
| (blank - all regions) | | ad_storage, ad_user_data, ad_personalization, analytics_storage, functionality_storage, personalization_storage |

For opt-out regions (e.g. US), add a second row:

| Region | Granted | Denied |
|--------|---------|--------|
| US | ad_storage, ad_user_data, ad_personalization, analytics_storage, functionality_storage, personalization_storage | |

## Documentation

- [How to install Kukie.io with Google Tag Manager](https://kukie.io/docs/installation-guides/install-kukie-via-google-tag-manager)
- [Allow Kukie.io in your Content Security Policy](https://kukie.io/docs/installation-guides/content-security-policy)
- [Google Consent Mode v2: Basic vs Advanced](https://kukie.io/docs/integrations/google-consent-mode-basic-vs-advanced)
- [Google's Banner Requirements](https://kukie.io/docs/integrations/google-banner-requirements)
- [Kukie Help Centre](https://kukie.io/docs)

## Support

- [Kukie Support](mailto:support@kukie.io)
- [GitHub Issues](https://github.com/kukie-io/kukie-gtm-template/issues)

## License

Apache 2.0
