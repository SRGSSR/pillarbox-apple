# Google Cast

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: google-cast-card, alt: "An image depicting the Google Cast logo.")
}

Wirelessly share video and audio to Google Cast–enabled receivers such as Chromecast, TVs, or speakers.

## Overview

[Google Cast](https://developers.google.com/cast) lets you stream video and audio to compatible receivers such as Chromecast, TVs, or speakers.

There are several ways to integrate Google Cast into an iOS app:

1. **Manual integration**: Follow the [official setup guide](https://developers.google.com/cast/docs/ios_sender#manual_setup) to add Google Cast manually to your project.

2. **Using the SRG SSR Google Cast SDK package**: SRG SSR distributes the [Google Cast SDK as a Swift Package](https://github.com/SRGSSR/google-cast-sdk). This simplifies retrieving and updating the SDK compared to downloading frameworks manually. However, you still need to perform the additional project setup as described in the [official documentation](https://developers.google.com/cast/docs/ios_sender/permissions_and_discovery#updating_your_app_on_ios_14).

3. **Using Castor (Recommended)**: [`Castor`](https://github.com/SRGSSR/castor) builds on top of the Google Cast SDK and provides a higher-level integration:
   * Modern default interfaces.
   * Simplified APIs compared to the raw SDK.
   * Built-in playlist management.
   * Excellent SwiftUI integration.

   With Castor, you benefit from both ease of use and a better user experience.

> Note: Google Cast integration is relevant only for iOS apps.
