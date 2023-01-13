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
