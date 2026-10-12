# Kukie CMP - Google Tag Manager Template

Google Consent Mode v2 integration template for [Kukie.io](https://kukie.io) consent management platform.

## Features

- Sets all 7 Google Consent Mode v2 parameters
- Per-region default consent settings, generated from your Kukie region rules
- A visitor with a stored choice or a privacy signal never starts granted
- Automatic consent updates from Kukie banner
- Ads data redaction support
- URL passthrough for ad click attribution
- Works with CDN bundles and legacy embed

## Setup

1. In GTM, go to Tags > New > Tag Configuration
2. Search for "Kukie CMP" in the Community Template Gallery
3. Enter your Kukie Site Key (in your Kukie dashboard: your site's Overview, Installation card, Google Tag Manager tab)
4. Under Default Consent Settings, add the rows your Kukie dashboard shows (same tab as the Site Key), one Add Row per row, with the Copy button for each field (see below)
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

## Default Consent Settings

The Kukie dashboard builds the rows from your site's region rules, so copy them from there rather than typing them. When you change a region rule, copy the rows again and publish the container. The rows are:

| Row | Region | Granted | Denied |
|-----|--------|---------|--------|
| Always | (blank: every other region) | security_storage | ad_storage, ad_user_data, ad_personalization, analytics_storage, functionality_storage, personalization_storage |
| When your rules allow data by default somewhere (Opt-Out, Notice Only, Hidden) | those regions, for example `US, CA, AU, ...` | what Accept all grants on your site, and security_storage | any type Accept all does not grant |
| When a state asks first inside such a country | for example `US-CA` | security_storage | the six types |

Google applies the most specific region ([Region-specific behavior](https://developers.google.com/tag-platform/security/guides/consent?consentmode=advanced#region-specific-behavior)). Keep the blank-region row: it covers every visitor no other row covers, including one Google cannot place. If you add no rows at all, the tag denies the six types and grants security_storage.

A visitor who already chose on this device (the `_cc_consent` or `kk_consent` cookie), or whose browser sends Global Privacy Control or Do Not Track, starts with every granted type denied but security_storage. The banner restores the choice, or applies the signal, once it loads.

## Documentation

- [How to install Kukie.io with Google Tag Manager](https://kukie.io/docs/installation-guides/install-kukie-via-google-tag-manager)
- [Allow Kukie.io in your Content Security Policy](https://kukie.io/docs/installation-guides/content-security-policy)
- [Google Consent Mode v2: Basic vs Advanced](https://kukie.io/docs/integrations/google-consent-mode-basic-vs-advanced)
- [Google's Banner Requirements](https://kukie.io/docs/integrations/google-banner-requirements)
- [Kukie Help Centre](https://kukie.io/docs)

## Support

- [Kukie Support](mailto:support@kukie.io)
- If Google tags are not getting Consent Mode signals, or you run into another Consent Mode setup, timing or measurement problem, email Kukie.io's Google client support at [google-support@kukie.io](mailto:google-support@kukie.io) first, before you contact Google. We answer within 1 business day.
- [GitHub Issues](https://github.com/kukie-io/kukie-gtm-template/issues)

## License

Apache 2.0
