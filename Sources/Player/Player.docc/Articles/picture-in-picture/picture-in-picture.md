# Picture in Picture

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: picture-in-picture-card, alt: "An image of PiP.")
}

Enable uninterrupted video playback experiences when multitasking.

## Overview

Pillarbox provides two modes of integration for Picture in Picture:

- Basic integration, which enables Picture in Picture automatically when the application is sent to the background.
- Advanced integration, which in addition allows the user to navigate your application while playing content with Picture in Picture. This requires the addition of a dedicated button with which Picture in Picture can be started interactively.

No matter the integration mode you choose you must setup your application first so that it can support Picture in Picture.

### Configure your app

For your application to be able to support Picture in Picture you must:

1. Ensure your app [background modes](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback#4182619) allow AirPlay.
2. Setup your [audio session category](https://developer.apple.com/documentation/avfoundation/streaming_and_airplay/supporting_airplay_in_your_app#2929254) to `.playback`.

### Basic integration

Integrating the basic functionality is straightforward, you just need to enable the `isPictureInPictureSupported` parameter when initializing the ``VideoView`` using the ``VideoView/init(player:gravity:isPictureInPictureSupported:)`` constructor.

``SystemVideoView`` does not support basic integration.

#### Testing your integration

To test your integration:

1. Start playing a video in your player.
2. Send your application to the background. Playback should continue in Picture in Picture.
3. Return to your application. Playback should automatically continue in the application.

### Advanced integration

Advanced integration is more involved and requires additional integration steps so that Picture in Picture can:

- Dismiss and restore your player user interface when appropriate.
- Continue playing even when the player user interface has been dismissed.

Advanced integration is available both for ``VideoView`` as well as ``SystemVideoView`` and is usually achieved as follows:

1. Enable `isPictureInPictureSupported` for a ``VideoView`` or ``SystemVideoView``.
2. Ensure your player view state can exist outside the view existence. One possible approach is to have a player view model which outlives its view, e.g. by storing it in a shared global state (e.g. a `static` property). The player view state should itself contain the ``Player`` instance used for playback.
3. Properly handle content updates in your shared player view state. Usually:
  a. When opening a content not being played: Update your player with the new item.
  b. When opening the same content already being played: Avoid updating your player so that playback can continue uninterrupted.
  c. When clearing the content: Remove all items currently in the player queue.
4. To release resources when the player view is not needed anymore (i.e. when the player view is closed without activating Picture in Picture, or when Picture in Picture ends), apply the ``SwiftUI/View/enabledForInAppPictureInPictureWithCleanup(perform:)`` modifier to the video view parent hierarchy, clearing your player view model state in its closure.
5. ``SystemVideoView`` provides a Picture in Picture button automatically. For ``VideoView``-based custom layouts you must add a ``PictureInPictureButton`` directly to your player interface.
6. To dismiss / restore the player user interface when entering / exiting Picture in Picture, set a Picture in Picture life cycle delegate with the ``PictureInPicture/setDelegate(_:)`` method. A  generally good candidate is any routing-aware class of your application. Dismiss the player view when Picture in Picture is about to start, and restore it when it ends, calling the required completion handler at the end of your restoration animation.

#### Testing your integration

To test your integration:

1. Start playing a video in your player.
2. Send your application to the background. Playback should continue in Picture in Picture.
3. Return to your application. The player view should be dismissed and playback should continue in the Picture in Picture overlay.
4. Tap on the Picture in Picture restoration button. Your player user interface should be restored without playback interruption.
5. Tap on the Picture in Picture button. Playback should continue in Picture in Picture, within your application.
6. Play the same content already being played. The player user interface should be restored without playback interruption.
7. Tap on the Picture in Picture button. Playback should continue in Picture in Picture, within your application.
8. Play another video. The player user interface should be restored with playback transitioning to the new content.

#### ``SystemVideoView`` inline display

The above instructions assume you are using either `VideoView` in a custom layout, or ``SystemVideoView`` presented full screen.

When ``SystemVideoView`` is presented inline, though, its close button is replaced with a maximization button to switch to full screen display. Picture in Picture can be enabled whether the inline player has been maximized or not, and for this reason any life cycle implementation for the inline system player should not dismiss the player view when Picture in Picture is about to start. Implementing view restoration is still required, though.

#### Limitations

Switching between a ``VideoView`` and a ``SystemVideoView`` for the content currently being played in Picture in Picture is not supported and leads to undefined behavior.
