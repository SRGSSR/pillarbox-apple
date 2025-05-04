# ``PillarboxAnalytics``

@Metadata {
    @PageColor(green)
}

Measure app usage in compliance with SRG SSR requirements.

## Overview

The PillarboxAnalytics framework provides a comprehensive toolkit for measuring app usage according to SRG SSR standards:

- **Internal Analytics:** Data is collected using the [Commanders Act](https://www.commandersact.com) analytics SDK.
- **Mediapulse Analytics:** [Mediapulse](https://www.mediapulse.ch), responsible for monitoring media consumption in Switzerland, receives measurements via the [comScore](https://www.comscore.com/) analytics SDK.

> Important: Proper implementation of analytics is essential. Non-compliance may result in rejection of your app or its measurements by the GD ADI team or Mediapulse.

### Measure app usage

PillarboxAnalytics enables app usage measurement through two main methods:

- <doc:page-views-article>
- <doc:events-article>

Streaming data is automatically tracked when using SRG SSR content with the PillarboxCoreBusiness framework. Ensure tracking is set up correctly by referring to the <doc:setup-article> article.

> Warning: The Commanders Act SDK used by PillarboxAnalytics [misuses user defaults](https://github.com/CommandersAct/iOSV5/issues/19) to store frequently changing parameters. Consequently, each Commanders Act page view or event (including streaming events) triggers a user defaults mutation. To prevent subtle performance issues in your application, ensure it does not perform excessive work [in response to user defaults changes](https://developer.apple.com/documentation/foundation/userdefaults#2926902).

### Transparency and data protection

To comply with Switzerland’s [New Federal Act on Data Protection (nFADP)](https://www.kmu.admin.ch/kmu/en/home/facts-and-trends/digitization/data-protection/new-federal-act-on-data-protection-nfadp.html), apps must integrate a user consent management system. For implementation details, refer to the <doc:user-consent-article> article.

### AdSupport and Identifier for Advertisers (IDFA)

The PillarboxAnalytics framework links against [AdSupport](https://developer.apple.com/documentation/adsupport), but it does not use or share the [IDFA](https://developer.apple.com/documentation/adsupport/asidentifiermanager/advertisingidentifier).

> Important: SRG SSR apps must **not** implement [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency) to ensure the IDFA remains inaccessible.

### App privacy details

When submitting an app to the App Store, provide accurate [app privacy details](https://developer.apple.com/app-store/app-privacy-details/) about data collection and usage.

Xcode Organizer can generate a [consolidated privacy report](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4239187), which includes data collected by Pillarbox and its third-party dependencies.

### Validation

Before submitting your app to production, validate it, especially after significant analytics updates. Contact the GD ADI team for assistance with the validation process.

## Topics

### Essentials

- <doc:setup-article>
- <doc:user-consent-article>

- ``Analytics``

### Configuration

- ``AnalyticsDataSource``
- ``AnalyticsDelegate``
- ``CommandersActGlobals``
- ``ComScoreGlobals``
- ``ComScoreConsent``
- ``Vendor``

### Page Views

- <doc:page-views-article>

- ``CommandersActPageView``
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
