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

- <doc:page-views-article>
- <doc:events-article>

> Important: Streaming measurements are automatically collected when playing SRG SSR content using the PillarboxCoreBusiness framework. Just ensure that tracking has been properly setup first. Please refer to <doc:setup-article> for more information.

### Transparency and data protection

To comply with the Swiss [New Federal Act on Data Protection (nFADP)](https://www.kmu.admin.ch/kmu/en/home/facts-and-trends/digitization/data-protection/new-federal-act-on-data-protection-nfadp.html) apps must implement some form of user consent management. Please read <doc:user-consent-article> for more information about how you can provide user consent information to the PillarboxAnalytics framework.

#### AdSupport and Identifier for advertisers (IDFA)

The PillarboxAnalytics framework always links against [AdSupport](https://developer.apple.com/documentation/adsupport) but the [IDFA](https://developer.apple.com/documentation/adsupport/asidentifiermanager/advertisingidentifier) is never used or shared by the PillarboxAnalytics framework.

> Important: SRG SSR apps must not implement [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency). This ensures that the IDFA can never be read unintentionally.

### App privacy details

When submitting an app to the App Store you must provide [App privacy details](https://developer.apple.com/app-store/app-privacy-details/) that accurately reflect which data is collected by your app and to what purpose.

To help you fill all required information Xcode organizer provides a way to generate a [consolidated privacy report for your app](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4239187). This report automatically contains privacy details associated with Pillarbox and its 3rd party dependencies.

### Validation

Your application should be validated before being submitted to production, at least when significant changes to analytics are made. Please contact the GD ADI team for more information.

## Topics

### Essentials

- <doc:setup-article>
- <doc:user-consent-article>

- ``Analytics``

### Configuration

- ``AnalyticsDataSource``
- ``CommandersActGlobals``
- ``ComScoreGlobals``
- ``ComScoreConsent``
- ``Vendor``

### Page Views

- <doc:page-views-article>
- <doc:web-content-tracking-article>

- ``CommandersActPageView``
- ``ComScorePageView``
- ``ContainerPageViewTracking``
- ``PageViewTracking``

### Events

- <doc:events-article>

- ``CommandersActEvent``

### Streaming

- ``CommandersActTracker``
- ``ComScoreTracker``

### Development and Testing

- ``AnalyticsListener``
- ``CommandersActContext``
- ``CommandersActDevice``
- ``CommandersActHit``
- ``CommandersActLabels``
- ``CommandersActUser``
- ``ComScoreHit``
- ``ComScoreLabels``
