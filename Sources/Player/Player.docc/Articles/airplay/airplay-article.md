# AirPlay

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: airplay-card, alt: "An image depicting the AirPlay video and audio logos.")
}

Wirelessly share video and audio to Apple TV or AirPlay-enabled receivers.

## Overview

> Important: AirPlay integration is relevant only for iOS apps. Note that iPad apps running on macOS or using Catalyst do not support AirPlay.

``Player`` provides built-in support for [AirPlay](https://developer.apple.com/airplay/) to compatible receivers. To enable AirPlay in your app, you need to configure your app settings and activate AirPlay on a per-player basis.

> Note: For detailed integration steps, refer to the <doc:supporting-airplay> tutorial.

### Configure your app

To support AirPlay in your app, follow these steps:

1. **Enable Background Modes:** Ensure your app’s background modes [include AirPlay support](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback#4182619).
2. **Set the Audio Session Category:** Configure your app’s [audio session category](https://developer.apple.com/documentation/avfoundation/streaming_and_airplay/supporting_airplay_in_your_app#2929254) to [`.playback`](https://developer.apple.com/documentation/avfaudio/avaudiosession/category/1616509-playback).

### Enable external playback for a player instance

To support AirPlay, a ``Player`` instance must have external playback enabled:

- External playback is enabled by default but can be customized using a ``PlayerConfiguration`` when creating a player instance.
- ``PlayerConfiguration`` also lets you define how external playback interacts with device mirroring over AirPlay.

### Make a player instance active

While multiple ``Player`` instances can exist in an app, only one at a time can share content via AirPlay:

- To activate a player instance, call ``Player/becomeActive()``. This action deactivates any other active player instances.
- To deactivate a player instance, use ``Player/resignActive()``. Note that players automatically resign when deinitialized.

### Add an AirPlay button

While AirPlay can be controlled from the iOS Control Center, including an AirPlay button in your app’s user interface improves usability:

- Add a ``RoutePickerView`` to your player layout to provide AirPlay controls directly in your app.
- Ensure you specify an explicit size for the ``RoutePickerView``, as it otherwise occupies all available parent space.
