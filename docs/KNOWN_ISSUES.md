# Known issues

The following document lists known Pillarbox issues. Entries with a feedback number (FBxxxxxxxx) have been reported to Apple and will hopefully be fixed in upcoming iOS and tvOS releases.

## Video view leak (FB11934227)

A bug in AVKit currently makes `SystemVideoView` leak resources after having interacted with the playback button.

### Workaround

No workaround is available yet.

## DRM-protected streams do not play in the simulator

DRM-protected streams do not play in the simulator. This is expected behavior as the required hardware features are not available in the simulator environment.

### Workaround

Use a physical device.

## Seeking to the end of an on-demand might confuse the player (FB12020197, FB12019796, FB12019343, FB11970329)

Seeking near the end of a content might sometimes confuse the player (image stuck while sound is still playing, for example).

### Workaround

No workaround is available yet.

## Very fast playlist navigation during AirPlay playback might confuse the player

When seeking between items very fast the receiver might get confused, not being able to cope with the number of demands and the associated network activity. As a result the receiver might get stuck.

### Workaround

We have mitigated AirPlay instabilities as much as possible so that fast navigation is possible in almost all practical cases. If an issue is encountered, though, closing and reopening the player should make playback possible again.

In some extreme cases it might happen that the AirPlay receiver is unable to recover from heavy usage. If this happens restarting the receiver will make it usable again.

## DRM playback is sometimes not possible anymore

It might happen that attempting to play DRM streams always ends with an error. The reason is likely an issue with key session management.

### Workaround

Kill and restart the application.

## Token-protected content is not playable on Apple TV 3rd generation devices

Token-protected content cannot be played on old Apple TV 3rd generation devices. An error is returned when attempting to play such content.

### Workaround

No workaround is available yet.

## Media type is unknown when playback is started after an AirPlay session has been established

The media type is `.unknown` if playback is started after an AirPlay session has been established. A correct value is delivered when AirPlay is enabled after playback has already been started, though.

As a result some behaviors based on the media type might not always be reliable over AirPlay.

### Workaround

No workaround is available yet.

## Media type is briefly incorrect when disabling AirPlay while the media type is still unknown

The media type can be `.unknown` if an AirPlay session was established before playback started (see previous issue). In such cases closing the AirPlay session ensures a correct media type is delivered, though for video it might briefly be set to `.audio` first.

### Workaround

No workaround is available yet.

## Audio duration is zero in Mac applications "Designed for iPad"

Pillarbox can be used in iPad applications run on Silicon Macs (_Designed for iPad_ destination) but audios played will have a reported duration of zero. As a result progress reported by `ProgressTracker` also remains stuck at zero.

### Workaround

No workaround is available yet.
