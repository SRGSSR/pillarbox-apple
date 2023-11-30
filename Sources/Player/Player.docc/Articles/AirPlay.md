# AirPlay

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: airplay-article-card, alt: "An image depicting the AirPlay video and audio logos.")
}

Enable video and audio wireless sharing to Apple TV or AirPlay‑enabled receivers.

## Overview

> Important: AirPlay integration is only meaningful for iOS apps.

``Player`` natively supports [AirPlay](https://developer.apple.com/airplay/) to compatible receivers. Enabling AirPlay in your app requires some general setup as well as activation on a player basis.

### Configure your app

For AirPlay to be available your app must be configured appropriately:

1. Ensure your app [background modes](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback#4182619) allow AirPlay.
2. Setup your [audio session category](https://developer.apple.com/documentation/avfoundation/streaming_and_airplay/supporting_airplay_in_your_app#2929254) to `.playback`.

### Enable external playback for a player instance

A `Player` instance must be enabled for external playback to allow AirPlay to be enabled. This is the default behavior but you can disable external playback for some instance using a custom ``PlayerConfiguration`` provided at creation time.

``PlayerConfiguration`` also allows you to choose how external playback must behave when device mirroring over AirPlay is enabled.

Note that enabling external playback is required but not sufficient for AirPlay to be possible for some ``Player`` instance. You namely also need to make the player instance active.

### Make a player instance active

Several ``Player`` instances can coexist in an app but only one at most is able to share its content over AirPlay.

When you want one player instance to take precedence call ``Player/becomeActive()``. Any other instance which might be active will resign in the process.

You can manually call ``Player/resignActive()`` to have a player resign. If not the player instance will automatically resign when deinitialized.

### Add an AirPlay button

For active player instances enabled for external playback AirPlay can be enabled from the iOS Control Center. Your player user interface should nonetheless always provide a button to enable AirPlay directly without leaving your app.

Adding an AirPlay button is as simple as adding a ``RoutePickerView`` to your player layout. You should usually provide an explicit size as the view itself otherwise takes all space available from its parent.
