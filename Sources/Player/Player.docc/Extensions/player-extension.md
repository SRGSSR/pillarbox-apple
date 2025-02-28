# ``PillarboxPlayer/Player``

## Topics

### Creating a Player

- ``init(item:configuration:)``
- ``init(items:configuration:)``

#### Configuring Player Behavior

- ``actionAtItemEnd``
- ``audiovisualBackgroundPlaybackPolicy``
- ``configuration``
- ``isMuted``
- ``repeatMode``
- ``shouldPlay``
- ``textStyleRules``

### Managing Player Items

- ``append(_:)``
- ``currentItem``
- ``insert(_:after:)``
- ``insert(_:before:)``
- ``items``
- ``move(_:after:)``
- ``move(_:before:)``
- ``nextItems``
- ``prepend(_:)``
- ``previousItems``
- ``remove(_:)``
- ``removeAllItems()``

### Controlling Playback

- ``canReplay()``
- ``pause()``
- ``play()``
- ``replay()``
- ``togglePlayPause()``

### Observing Playback Properties

- ``chunkDuration``
- ``date()``
- ``error``
- ``isExternalPlaybackActive``
- ``mediaType``
- ``metadata``
- ``metrics()``
- ``playbackState``
- ``presentationSize``
- ``propertiesPublisher``
- ``rate``
- ``time()``
- ``version``

### Observing Playback Time

- ``boundaryTimePublisher(for:queue:)``
- ``periodicTimePublisher(forInterval:queue:)``

### Seeking Through Media

- ``canSeek(to:)``
- ``seek(_:smooth:completion:)``
- ``seek(to:completion:)-9bknb``
- ``seek(to:completion:)-2ypz8``
- ``seek(to:completion:)-1tbeq``

### Skipping Through Media

- ``canSkipBackward()``
- ``canSkipForward()``
- ``canSkipToDefault()``
- ``skipBackward(completion:)``
- ``skipForward(completion:)``
- ``skipToDefault(completion:)``

### Creating Player Positions

- ``after(_:)``
- ``at(_:)``
- ``before(_:)``
- ``near(_:)``
- ``to(_:toleranceBefore:toleranceAfter:)``

### Navigating Between Items

- ``advanceToNext()``
- ``advanceToNextItem()``
- ``canAdvanceToNext()``
- ``canAdvanceToNextItem()``
- ``canReturnToPrevious()``
- ``canReturnToPreviousItem()``
- ``currentItem``
- ``returnToPrevious()``
- ``returnToPreviousItem()``

### Managing Media Selection

- ``currentMediaOption(for:)``
- ``mediaOption(for:)``
- ``mediaSelectionCharacteristics``
- ``mediaSelectionOptions(for:)``
- ``mediaSelectionPreferredLanguages(for:)``
- ``select(mediaOption:for:)``
- ``selectedMediaOption(for:)``
- ``setMediaSelection(preferredLanguages:for:)``

### Controlling Playback Speed

- ``effectivePlaybackSpeed``
- ``playbackSpeed``
- ``playbackSpeedRange``
- ``setDesiredPlaybackSpeed(_:)``

### Accessing Player Internals

- ``systemPlayer``

### Integrating with Control Center and AirPlay

- ``becomeActive()``
- ``resignActive()``

### Tracking Playback

- ``isTrackingEnabled``
- ``currentSessionIdentifiers(trackedBy:)``

### Observing Metrics

- ``metricEventsPublisher``
- ``periodicMetricsPublisher(forInterval:queue:limit:)``

### Integrating with SwiftUI Menus

- ``mediaSelectionMenu(characteristic:)``
- ``playbackSpeedMenu(speeds:)``
- ``standardSettingsMenu()``
