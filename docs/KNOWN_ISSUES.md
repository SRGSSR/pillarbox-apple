# Known issues

The following document lists known Pillarbox issues. Entries with a feedback number (FBxxxxxxxx) have been reported to Apple and will hopefully be fixed in upcoming iOS and tvOS releases.

## Video view leak (FB11934227)

A bug in AVKit currently makes `SystemVideoView` leak resources after having interacted with the playback button on iOS 16. The issue has been fixed on iOS 17.

### Workaround

No workaround is available yet.

## DRM-protected streams do not play in the simulator

DRM-protected streams do not play in the simulator. This is expected behavior as the required hardware features are not available in the simulator.

### Workaround

Use a physical device.

## Seeking to the end of an on-demand might confuse the player (FB12020197, FB12019796, FB12019343, FB11970329)

Seeking near the end of a content might sometimes confuse the player (image stuck while sound is still playing, for example).

### Workaround

No workaround is available yet.

## DRM playback is sometimes not possible anymore

It might happen that attempting to play DRM streams always ends with an error. The reason is likely an issue with key session management.

### Workaround

Kill and restart the application.

## Token-protected content is not playable on Apple TV 3rd generation devices

Token-protected content cannot be played on old Apple TV 3rd generation devices. An error is returned when attempting to play such content.

### Workaround

No workaround is available yet.

## Media type is unknown when playback is started after an AirPlay session has been established (FB5464600)

The media type is `.unknown` if playback is started after an AirPlay session has been established. A correct value is delivered when AirPlay is enabled after playback has already been started, though.

As a result some behaviors based on the media type might not always be reliable over AirPlay.

### Workaround

No workaround is available yet.

## Media type is briefly incorrect when disabling AirPlay while the media type is still unknown

The media type can be `.unknown` if an AirPlay session was established before playback started (see previous issue). In such cases closing the AirPlay session ensures a correct media type is delivered, though for video it might briefly be set to `.audio` first.

### Workaround

No workaround is available yet.

## Audio duration is zero in Mac applications "Designed for iPad" (FB12765347)

Pillarbox can be used in iPad applications run on Silicon Macs (_Designed for iPad_ destination) but audios played will have a reported duration of zero. As a result progress reported by `ProgressTracker` also remains stuck at zero.

### Workaround

No workaround is available yet.

## AirPlay does not work in Mac applications "Designed for iPad" (FB15343579)

Pillarbox can be used in iPad applications run on Silicon Macs (_Designed for iPad_ destination) but AirPlay does not work. Playback fails.

### Workaround

No workaround is available yet.

## Playback of a livestream in a playlist might fail if the previous item was played at a speed > 1

When chaining an on-demand stream played at a speed > 1 to a livestream (without DVR) in a playlist, livestream playback might fail with a Core Media error. If there is an item after it the livestream item will simply be skipped, otherwise the player will end in a failed state.

### Workaround

No workaround is available yet.

## Sound of a player casting to AirPlay incorrectly overlaps with sound of local player instances (FB12311238)

When casting a player to AirPlay while other players are playing other content locally (even muted), sound of these other instances overlaps with the sound of the main instance played on the AirPlay receiver.

### Workaround

Pause players playing content locally.

## Presentation size cannot be determined when AirPlay is enabled (FB12080967)

When AirPlay is activated the value of the `AVPlayerItem.presentationSize` property is always zero. It is therefore not possible to tell whether a video or audio is played when AirPlay is enabled.

### Workaround

No workaround is available yet.

## Tap gesture recognizers prevent RoutePickerView from showing its route selection dialog (FB12663995)

When a layout contains a `RoutePickerView` as well as a tap gesture recognizer (even simultaneously recognizing), the presence of the gesture recognizer prevents the route picker from displaying the associated route selection dialog.

### Workaround

Move tap gesture recognizers in your layout so that they do not overlap with the `RoutePickerView`.

## Subtitle selection might be incorrect near the end of the current item (FB13070742)

When approaching the end of the current item, and if there is a next item in the list, subtitle selection might suddenly change to an incorrect value. Subtitles displayed on screen, though, remain the same as before.

### Workaround

No workaround is available yet.

## Slow seeking when Spatial audio is enabled for connected AirPods (FB13322077)

Seeks might feel sluggish when Spatial audio is enabled for connected AirPods. This only happens when a player view supporting Picture is Picture is displayed while seeking is made.

### Workaround

No workaround is available yet.

## Playback is paused when switching between 360° and standard videos in a playlist

Playback is paused when switching between 360° and standard videos in a playlist. This results from the deallocation of video nodes in monoscopic scenes.

### Workaround

Playback can be resumed, either programmatically or by providing the user with playback controls.

## Control Center playback button state is incorrect in multi-player configurations (FB13684239)

When mutiple player instances are used and one of them has been made active, the  Control Center playback button state does not always correctly reflect the state of the active player, but is altered by the state of the other available players as well.

### Workaround

No workaround is available yet.
