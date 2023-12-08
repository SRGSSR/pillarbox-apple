# Picture in Picture

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: picture-in-picture-card, alt: "An image of the Picture in Picture symbol.")
}

Enable uninterrupted video playback experiences when multitasking.

## Overview

Pillarbox provides two modes of integration for Picture in Picture:

- **Basic integration**, which enables Picture in Picture automatically when the application is sent to the background.
- **Advanced integration**, which in addition allows the user to navigate your application while playing content with Picture in Picture. This requires the addition of a dedicated button with which Picture in Picture can be started interactively.

No matter the integration mode you choose you must configure your app properly so that it can support Picture in Picture.

> Note: For step-by-step integration instructions have a look at the associated <doc:supporting-basic-picture-in-picture> tutorial.

### Configure your app

For your application to be able to support Picture in Picture you must:

1. Ensure your app [background modes](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback#4182619) allow AirPlay.
2. Setup your [audio session category](https://developer.apple.com/documentation/avfoundation/streaming_and_airplay/supporting_airplay_in_your_app#2929254) to [`.playback`](https://developer.apple.com/documentation/avfaudio/avaudiosession/category/1616509-playback).

### Basic integration

To enable basic Picture in Picture integration simply instantiate a video view with ``VideoView/init(player:gravity:isPictureInPictureSupported:)``, setting the `isPictureInPictureSupported` parameter to `true`.

> ``SystemVideoView`` does not support basic Picture in Picture integration.

#### Testing your integration

1. Start playing a video in your player.
2. Send your application to the background. Playback should continue in Picture in Picture.
3. Return to your application. Playback should automatically continue in the application.

### Advanced integration

Advanced integration is more involved and requires additional integration steps so that Picture in Picture can:

- Dismiss and restore your player user interface when appropriate.
- Continue playing even when the player user interface has been dismissed.

Advanced integration is available both for ``VideoView`` as well as ``SystemVideoView`` and is usually achieved as follows:

1. Enable `isPictureInPictureSupported` for a ``VideoView`` or ``SystemVideoView`` at construction time.
2. Ensure your player view state is persisted even when the player view is not displayed. One possible approach is to have a player view model which outlives its view, e.g. by storing it using a shared global state (e.g. a `static` property). The player view state should itself contain the ``Player`` instance used for playback.
3. Properly handle content updates in your shared player view state. This usually means you should:
    - Update your player when a new content is being played.
    - Avoid updating your player when the same content is played so that playback can continue uninterrupted.
    - Remove all items currently in the player queue when content playback must stop.
4. To release resources when the player view is not needed anymore (i.e. when the player view is closed without activating Picture in Picture, or when Picture in Picture ends), apply the ``SwiftUI/View/enabledForInAppPictureInPictureWithCleanup(perform:)`` modifier to the video view parent hierarchy, clearing your player view model state in its associated closure.
5. ``SystemVideoView`` provides a Picture in Picture button automatically. In ``VideoView``-based custom layouts add a ``PictureInPictureButton``.
6. To dismiss / restore the player user interface when entering / exiting Picture in Picture, set a Picture in Picture life cycle delegate with the ``PictureInPicture/setDelegate(_:)`` method. A  generally good candidate is any routing-aware class of your application. Dismiss the player view when Picture in Picture is about to start and restore it when it ends.

> Warning: Switching between a ``VideoView`` and a ``SystemVideoView`` for the content currently being played in Picture in Picture is not supported and leads to undefined behavior.

#### Testing your integration

1. Start playing a video in your player.
2. Send your application to the background. Playback should continue in Picture in Picture.
3. Return to your application. The player view should be dismissed and playback should continue in the Picture in Picture overlay.
4. Tap on the Picture in Picture restoration button. Your player user interface should be restored without playback interruption.
5. Tap on the Picture in Picture button. Playback should continue in Picture in Picture, within your application.
6. Play the same video already being played. The player user interface should be restored without playback interruption.
7. Tap on the Picture in Picture button. Playback should continue in Picture in Picture, within your application.
8. Play another video. The player user interface should be restored with playback transitioning to the new content.

#### System video view inline display

The above instructions assume you are using either `VideoView` in a custom layout, or  that ``SystemVideoView`` is presented full screen.

When ``SystemVideoView`` is presented inline, though, its close button is replaced with a maximization button to switch to full screen display. Picture in Picture can be enabled whether the inline player has been maximized or not, and for this reason any life cycle implementation for the inline system player should not dismiss the player view when Picture in Picture is about to start. Implementing view restoration is still required, though.
