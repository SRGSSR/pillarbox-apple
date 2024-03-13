# AirPlay

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: airplay-card, alt: "An image depicting the AirPlay video and audio logos.")
}

Enable video and audio wireless sharing to Apple TV or AirPlay‑enabled receivers.

## Overview

> Important: AirPlay integration is only meaningful for iOS apps.

``Player`` natively supports [AirPlay](https://developer.apple.com/airplay/) to compatible receivers. Enabling AirPlay in your app requires some general setup as well as activation on a player basis.

> Note: For step-by-step integration instructions have a look at the associated <doc:supporting-airplay> tutorial.

### Configure your app

For your application to be able to support AirPlay you must:

1. Ensure your app [background modes](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback#4182619) allow AirPlay.
2. Setup your [audio session category](https://developer.apple.com/documentation/avfoundation/streaming_and_airplay/supporting_airplay_in_your_app#2929254) to [`.playback`](https://developer.apple.com/documentation/avfaudio/avaudiosession/category/1616509-playback).

### Enable external playback for a player instance

A ``Player`` instance must support external playback to be used with AirPlay.

This behavior is enabled by default but can be tailored to your needs using a custom ``PlayerConfiguration`` provided when instantiating a player. ``PlayerConfiguration`` also allows you to choose how external playback must behave when device mirroring over AirPlay is enabled.

Note that enabling external playback is required but not sufficient for AirPlay to be possible for some ``Player`` instance. You also need to make the player instance active.

### Make a player instance active

Several ``Player`` instances can coexist in an app but only one at most is able to share its content over AirPlay.

When you want one player instance to take precedence call ``Player/becomeActive()``. Any other instance which might be active will resign in the process.

You can manually call ``Player/resignActive()`` to have a player resign. Note that a player instance will automatically resign when deinitialized.

### Add an AirPlay button

AirPlay can be toggled from the iOS Control Center but player user interfaces should also provide a button so that users can enable AirPlay without leaving your app.

Adding an AirPlay button is as simple as adding a ``RoutePickerView`` to your player layout. You must usually provide an explicit size as the view itself otherwise takes all space made available by its parent.
