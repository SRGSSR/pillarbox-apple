# Known issues

The following document lists known Pillarbox issues. Entries with a feedback number (FBxxxxxxxx) have been reported to Apple and will hopefully be fixed in upcoming iOS and tvOS releases.

Detailed information about these reports is available from our [Apple feedback public repository](https://github.com/SRGSSR/apple-bug-reports).

## Video view leak (FB11934227)

A bug in AVKit makes `SystemVideoView` leak resources after the user has interacted with the playback button.

> [!IMPORTANT]
> This issue has been fixed in iOS 17.

### Workaround

No workaround is available yet.

## DRM-protected content does not play in the simulator

DRM-protected streams do not play in the simulator. This is expected behavior as the required hardware features are not available in the simulator.

### Workaround

Use a physical device.

## DRM-protected content playback crashes when debugging on macOS

When running an iPad app on macOS, attempting to play DRM-protected content while debugging causes the app to crash.

### Workaround

Disable _Debug executable_ in the associated scheme.

## Seeking to the end of an on-demand stream might confuse the player (FB12020197, FB12019343, FB11970329)

Seeking near the end of on-demand content might sometimes confuse the player (for example, the image freezes while sound keeps playing).

### Workaround

No workaround is available yet.

## DRM playback is sometimes not possible anymore (FB19383686)

Attempts to play DRM streams might consistently fail with an error. The cause is likely an issue with key session management.

> [!IMPORTANT]
> This issue has been fixed in iOS 26.3.

### Workaround

Kill and restart the application.

## Token-protected content is not playable on Apple TV 3rd generation devices

Token-protected content cannot be played on Apple TV 3rd generation devices. An error is returned when attempting to play such content.

### Workaround

No workaround is available yet.

## Media type is unknown when playback is started after an AirPlay session has been established (FB5464600, FB20914272)

The media type is `.unknown` if playback is started after an AirPlay session has been established. A correct value is delivered when AirPlay is enabled after playback has already been started, though.

As a result, some behaviors based on the media type might not always be reliable over AirPlay.

### Workaround

No workaround is available yet.

## Media type is briefly incorrect when disabling AirPlay while the media type is still unknown

The media type can be `.unknown` if an AirPlay session was established before playback started (see previous issue). In such cases, closing the AirPlay session ensures a correct media type is delivered, though for video it might briefly be set to `.audio` first.

### Workaround

No workaround is available yet.

## AirPlay does not work in Mac applications "Designed for iPad" (FB15343579)

Pillarbox can be used in iPad applications running on Apple silicon Macs (_Designed for iPad_ destination), but playback over AirPlay fails.

### Workaround

No workaround is available yet.

## Playback of a livestream in a playlist might fail if the previous item was played at a speed > 1

When chaining an on-demand stream played at a speed > 1 to a livestream (without DVR) in a playlist, livestream playback might fail with a Core Media error. If another item follows, the livestream item is simply skipped; otherwise, the player ends in a failed state.

### Workaround

No workaround is available yet.

## Sound of a player casting to AirPlay incorrectly overlaps with sound of local player instances (FB12311238)

When casting a player to AirPlay while other players are playing other content locally (even muted), the sound of these other instances overlaps with the sound of the main instance played on the AirPlay receiver.

### Workaround

Pause players playing content locally.

## Presentation size cannot be determined when AirPlay is enabled (FB12080967, FB20914272)

When AirPlay is enabled, the value of the `AVPlayerItem.presentationSize` property is always zero. It is therefore not possible to tell whether video or audio is being played.

### Workaround

No workaround is available yet.

## Tap gesture recognizers prevent RoutePickerView from showing its route selection dialog (FB12663995)

When a layout contains a `RoutePickerView` as well as a tap gesture recognizer (even simultaneously recognizing), the presence of the gesture recognizer prevents the route picker from displaying the associated route selection dialog.

> [!IMPORTANT]
> This issue has been fixed in iOS 18.

### Workaround

Move tap gesture recognizers in your layout so that they do not overlap with the `RoutePickerView`.

## Subtitle selection might be incorrect near the end of the current item (FB13070742)

When approaching the end of the current item, and if there is a next item in the list, subtitle selection might suddenly change to an incorrect value. Subtitles displayed on screen, though, remain the same as before.

### Workaround

No workaround is available yet.

## Slow seeking when Spatial Audio is enabled for connected AirPods (FB13322077)

Seeking might feel sluggish when Spatial Audio is enabled for connected AirPods. This only happens when a player view supporting Picture in Picture is displayed while seeking.

### Workaround

No workaround is available yet.

## Control Center playback button state is incorrect in multi-player configurations (FB13684239)

When multiple player instances are used and one of them has been made active, the Control Center playback button state does not always correctly reflect the state of the active player, but is altered by the state of the other available players as well.

### Workaround

No workaround is available yet.

## DRM content fails to play after extended background time

If the app stays in the background for an extended period (around 24 hours) without being terminated, playback of DRM-protected content may consistently fail.

### Workaround

Instead of using an encrypted `PlayerItem`, create a custom player item and handle key loading via an `AVAssetResourceLoaderDelegate`.

## Device auto-lock may not be prevented during video playback (FB20938762)

On iOS 26 and later, the device screen may dim and eventually auto-lock during video playback, even when `preventsDisplaySleepDuringVideoPlayback` is set to `true` for an `AVPlayer` (the default behavior).

### Workaround

This issue is caused by a Picture in Picture regression introduced in iOS 26.
Avoid dynamically changing the value of `VideoView.supportsPictureInPicture(_:)` or `SystemVideoView.supportsPictureInPicture(_:)` while a video view is visible.

## The player may remain silent after toggling `isMuted` (FB21089410)

Due to an `AVQueuePlayer` issue, toggling `isMuted` can cause the player to remain permanently silent. This occurs when playback is near the end of an item and another item is expected to play next as part of a playlist, or when a repeat mode is enabled.

> [!IMPORTANT]
> This issue has been fixed in an iOS 26 minor release.

### Workaround

No workaround is available yet. Audio is restored when transitioning between items, when the player is paused and resumed, or when a seek operation occurs.

## Playback incorrectly jumps to the live edge when resuming a DVR video livestream after an interruption (FB21701670)

When playing a video livestream that offers a DVR window, the player incorrectly resumes at the live edge after an interruption (for example, an alarm) instead of resuming from the previous playback position.

### Workaround

Apps that require this behavior to be handled correctly can manage [audio session interruptions](https://developer.apple.com/documentation/avfaudio/handling-audio-interruptions) to save and restore the current playback position.

## FairPlay-protected content playback fails with Lightning adapter (A1438) on iOS 18 and above (FB22052832)

When using an official Lightning-to-HDMI Apple adapter (A1438) to connect a Lightning-equipped iOS device to a screen, using an appropriate HDMI cable, playback of FairPlay-protected content always fails with an error on iOS 18 and later.

### Workaround

No workaround is available yet.

## Negative metrics after audio track switch (FB22519249)

Some increments reported in `Metrics` may contain negative values immediately following an audio track switch.

### Workaround

No workaround is available yet.

## Downloaded files might remain after cleanup

If a download is pending but has not started yet when the app is terminated, the location of its file can no longer be retrieved. As a result, the file cannot be cleaned up.

### Workaround

These orphaned download files are typically very small (at most a few kilobytes). They can be removed manually from the Storage section of the Settings app, or are eventually reclaimed by the system.

## Offline playback fails due to media selection picking variants declared in the master playlist but not available offline (FB24445920)

When playing a downloaded stream offline (for example, in Airplane Mode without Wi-Fi), the player may incorrectly attempt to load variants that are declared in the master playlist but not available offline. Playback then fails with a network error ("The Internet connection appears to be offline").

### Workaround

Use `DownloadMediaSelectionPreference.all` to download all languages. `DownloadMediaSelectionPreference.automatic` generally works as well, provided users do not change their device language after downloading the content.

## The system video view might present options unavailable for offline playback (FB24446455)

When playing downloaded content, `SystemVideoView` might present options that are not available for offline playback. Selecting one of these options can trigger unexpected network activity or cause playback to stall while attempting to load content that is unavailable offline.

### Workaround

No workaround is available yet.

## Standard Pillarbox menus may prevent players from being immediately deallocated on iOS 27 (FB24486991)

Objects whose properties are bound to items displayed in a `Menu` are not immediately deallocated on iOS 27. As a result, standard menus provided by Pillarbox may retain the associated player longer than expected. This can lead to playback unexpectedly continuing in the background.

### Workaround

No workaround is available yet.
