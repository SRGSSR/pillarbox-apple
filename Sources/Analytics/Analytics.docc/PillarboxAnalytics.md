# ``PillarboxAnalytics``

@Metadata {
    @PageColor(green)
}

Measure app usage according to SRG SSR requirements.

## Overview

The PillarboxAnalytics framework provides a toolbox to measure app usage according to SRG SSR requirements:

- Analytics for internal usage, gathered using [Commanders Act](https://www.commandersact.com) analytics SDK.
- Analytics for [Mediapulse](https://www.mediapulse.ch), an organization charged with collecting media consumption data in Switzerland. These measurements are forwarded using [comScore](https://www.comscore.com/) analytics SDK.

> Important: Proper measurements are critical. The GD ADI team or Mediapulse might reject your application or its measurements should you implement analytics incorrectly.

### Measure app usage

The PillarboxAnalytics framework lets you measure application usage in two ways:

- <doc:page-views>
- <doc:events>

> Important: Streaming measurements are automatically collected when playing SRG SSR content using the PillarboxCoreBusiness framework. Just ensure that tracking has been properly setup first. Please refer to <doc:setup> for more information.

### Transparency and data protection

To comply with the Swiss [New Federal Act on Data Protection (nFADP)](https://www.kmu.admin.ch/kmu/en/home/facts-and-trends/digitization/data-protection/new-federal-act-on-data-protection-nfadp.html) apps must implement some form of user consent management. Please read <doc:user-consent> for more information about how you can provide user consent information to the PillarboxAnalytics framework.

#### AdSupport and Identifier for advertisers (IDFA)

The PillarboxAnalytics framework always links against [AdSupport](https://developer.apple.com/documentation/adsupport) but the [IDFA](https://developer.apple.com/documentation/adsupport/asidentifiermanager/advertisingidentifier) is never used or shared by the PillarboxAnalytics framework.

> Important: SRG SSR apps must not implement [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency). This ensures that the IDFA can never be read unintentionally.

### App Privacy details

When submitting an app to the App Store you must provide [App Privacy details](https://developer.apple.com/app-store/app-privacy-details/). The PillarboxAnalytics framework collects Identifiers (User ID) and usage data (Product Interaction) but never linked to a user.

### Validation

Your application should be validated before being submitted to production, at least when significant changes to analytics are made. Please contact the GD ADI team for more information.

## Topics

### Essentials

- <doc:setup>
- <doc:user-consent>

### Page Views

- <doc:page-views>
- <doc:web-content-tracking>

### Events

- <doc:events>
