# Picture in Picture

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: picture-in-picture-card, alt: "An image of the Picture in Picture symbol.")
}

Enable uninterrupted video playback while multitasking.

## Overview

Pillarbox supports two integration modes for Picture in Picture (PiP):

- **Basic Integration:** Automatically activates PiP when the app is sent to the background.
- **Advanced Integration:** Allows users to navigate within your app while continuing content playback in PiP. This mode requires a dedicated button to enable PiP interactively.

Regardless of the integration mode you choose, your app must be properly configured to support PiP.

> Note: For step-by-step instructions, refer to the <doc:supporting-basic-picture-in-picture> tutorial.

### Configure your app

To enable PiP, ensure the following configurations are applied:

1. **Background Modes:** Enable PiP support in your app’s [background modes](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback#4182619).
2. **Audio Session:** Set the [audio session category](https://developer.apple.com/documentation/avfoundation/streaming_and_airplay/supporting_airplay_in_your_app#2929254) category to [`.playback`](https://developer.apple.com/documentation/avfaudio/avaudiosession/category/1616509-playback).

### Basic integration

To enable basic PiP functionality, follow these steps:

1. Instantiate a ``VideoView``.
2. Apply the ``VideoView/supportsPictureInPicture(_:)`` modifier to enable PiP.

> Note: ``SystemVideoView`` does not support basic PiP integration.

#### Testing your integration

To test your integration, follow these steps:

1. Start playing a video in your player.
2. Send the app to the background. Playback should continue in PiP.
3. Return to the app. Playback should resume within the app automatically.

### Advanced integration

Advanced integration, available for ``VideoView`` as well as ``SystemVideoView``, is more involved and requires additional integration steps so that PiP can:

- Dismiss and restore your player user interface when appropriate.
- Continue playing even when the player user interface has been dismissed.

To enable advanced PiP functionality, follow these steps:

1. Apply the appropriate PiP modifier:
    - ``VideoView/supportsPictureInPicture(_:)`` for ``VideoView``.
    - ``SystemVideoView/supportsPictureInPicture(_:)`` for ``SystemVideoView``.
2. Implement ``PictureInPicturePersistable`` in the associated class to persist the player view state. You can use optional methods to hook into the PiP lifecycle as needed.
3. Handle shared player view state updates effectively:
    - Update the player for new content.
    - Avoid reloading the same content to prevent playback interruptions.
    - Clear the player queue when stopping playback.
4. Apply the ``SwiftUICore/View/enabledForInAppPictureInPicture(persisting:)`` modifier to persist player state during PiP playback.
5. Update player instantiation to recover persisted state from ``PictureInPicturePersistable/persisted`` or create a new state if none exists.
6. Add a ``PictureInPictureButton`` for custom ``VideoView`` layouts. (``SystemVideoView`` provides this button automatically.)
7. Manage PiP lifecycle events using the ``PictureInPicture/delegate`` property:
    - Dismiss the player interface when PiP starts.
    - Restore the player interface when PiP ends.

> Warning: Switching between ``VideoView`` and ``SystemVideoView`` for content played in PiP leads to undefined behavior.

#### Testing your integration

To test your integration, follow these steps:

1. Start playing a video in your player.
2. Send the app to the background. Playback should continue in PiP.
3. Return to the app. The player view should have been dismissed, with playback continuing in PiP.
4. Tap the PiP restoration button. The player interface should restore without playback interruption.
5. Tap the PiP button within the app. Playback should seamlessly transition to PiP.
6. Play the same video already in PiP. The player interface should restore without interrupting playback.
7. Tap the PiP button within the app. Playback should seamlessly transition to PiP.
8. Play a different video. The interface should restore while transitioning playback to the new content.

#### System video view inline display

When using ``SystemVideoView`` inline (not fullscreen), its close button is replaced with a maximize button to enable fullscreen mode. If you want to dismiss the view containing the inline player when PiP starts, wait for the ``PictureInPictureDelegate/pictureInPictureDidStart()`` callback to avoid playback interruptions.

> Warning: Automatic PiP activation (e.g., swiping to go Home) may not work if multiple ``SystemVideoView`` instances with PiP enabled are active simultaneously.
