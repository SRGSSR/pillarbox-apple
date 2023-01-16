# Known issues

The following document lists known Pillarbox issues. Entries with a feedback number (FBxxxxxxxx) have been reported to Apple and will hopefully be fixed in upcoming iOS and tvOS releases.

## Video view leak (FB11934227)

A bug in AVKit currently makes `SystemVideoView` leak resources after having interacted with the playback button.

### Workaround

No workaround is available yet.

## Stuck periodic time observers with audio playlists played over AirPlay

A bug with AVKit and AirPlay prevents time observers from working properly in playlists. After transitioning to another audio item in a playlist no more periodic time observer updates will be received. Reported times remain stuck at zero, which means:

- `ProgressTracker` does not report progress anymore.
- Sliders found in user interface components are not updated anymore.

### Workaround

No workaround is available yet.

## DRM-protected streams do not play in the simulator

DRM-protected streams do not play in the simulator. This is expected behavior as the required hardware features are not available in the simulator environment.

### Workaround

Use a physical device.

## Seeking to the end of an on-demand stream is limited

Seeks are currently prevented in the last 12 seconds of an on-demand stream to mitigate known player instabilities. If seeking is made within this window playback will resume at the nearest safely reachable location.

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