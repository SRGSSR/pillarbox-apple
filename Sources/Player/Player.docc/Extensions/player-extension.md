# ``PillarboxPlayer/Player``

## Topics

### Initializers

- ``init(item:configuration:)``
- ``init(items:configuration:)``

### Items

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

### Media Selection

- ``currentMediaOption(for:)``
- ``mediaOption(for:)``
- ``mediaSelectionCharacteristics``
- ``mediaSelectionOptions(for:)``
- ``mediaSelectionPreferredLanguages(for:)``
- ``select(mediaOption:for:)``
- ``selectedMediaOption(for:)``
- ``setMediaSelection(preferredLanguages:for:)``

#### Behavior

- ``actionAtItemEnd``
- ``configuration``
- ``repeatMode``
- ``shouldPlay``
- ``textStyleRules``

### Navigation

- ``advanceToNextItem()``
- ``canAdvanceToNextItem()``
- ``canReturnToPreviousItem()``
- ``returnToPreviousItem()``
- ``currentItem``

### Playback

- ``audiovisualBackgroundPlaybackPolicy``
- ``pause()``
- ``play()``
- ``togglePlayPause()``

### Playback Speed

- ``effectivePlaybackSpeed``
- ``playbackSpeed``
- ``playbackSpeedRange``
- ``setDesiredPlaybackSpeed(_:)``

### Properties

- ``chunkDuration``
- ``configuration``
- ``error``
- ``isExternalPlaybackActive``
- ``isMuted``
- ``mediaType``
- ``metadata``
- ``playbackState``
- ``presentationSize``
- ``propertiesPublisher``
- ``rate``
- ``systemPlayer``
- ``version``

### Current State

- ``date()``
- ``metrics()``
- ``time()``

### Replay

- ``canReplay()``
- ``replay()``

### Seek

- ``canSeek(to:)``
- ``seek(_:smooth:completion:)``
- ``seek(to:completion:)-9bknb``
- ``seek(to:completion:)-2ypz8``
- ``seek(to:completion:)-1tbeq``
- ``after(_:)``
- ``at(_:)``
- ``before(_:)``
- ``near(_:)``
- ``to(_:toleranceBefore:toleranceAfter:)``

### Skip

- ``canSkipBackward()``
- ``canSkipForward()``
- ``skipBackward(completion:)``
- ``skipForward(completion:)``

### Skip to Default

- ``canSkipToDefault()``
- ``skipToDefault(completion:)``

### Smart Navigation

- ``advanceToNext()``
- ``canAdvanceToNext()``
- ``canReturnToPrevious()``
- ``returnToPrevious()``

### System Integration

- ``becomeActive()``
- ``resignActive()``

### Time Publisher

- ``boundaryTimePublisher(for:queue:)``
- ``periodicTimePublisher(forInterval:queue:)``

### Tracking

- ``isTrackingEnabled``
- ``currentSessionIdentifiers(trackedBy:)``

### Metrics

- ``metricEventsPublisher``
- ``periodicMetricsPublisher(forInterval:queue:limit:)``

### User Interface

- ``mediaSelectionMenu(characteristic:)``
- ``playbackSpeedMenu(speeds:)``
- ``standardSettingMenu()``
