# ``PillarboxPlayer/Player``

## Topics

### Initializers

- ``init(item:configuration:)``
- ``init(items:configuration:)``

### Items

- ``append(_:)``
- ``currentIndex``
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

#### Style

- ``textStyleRules``

### Navigation

- ``advanceToNextItem()``
- ``canAdvanceToNextItem()``
- ``canReturnToPreviousItem()``
- ``returnToPreviousItem()``
- ``setCurrentIndex(_:)``

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
- ``playbackState``
- ``presentationSize``
- ``propertiesPublisher``
- ``rate``
- ``systemPlayer``
- ``time``
- ``version``

### Replay

- ``canReplay()``
- ``replay()``

### Seek

- ``canSeek(to:)``
- ``seek(_:smooth:completion:)``
- ``seek(to:completion:)``
- ``after(_:)``
- ``at(_:)``
- ``before(_:)``
- ``near(_:)``
- ``to(_:toleranceBefore:toleranceAfter:)``

### Setup

- ``becomeActive()``
- ``configuration``
- ``resignActive()``

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

### Time Publisher

- ``boundaryTimePublisher(for:queue:)``
- ``periodicTimePublisher(forInterval:queue:)``

### Tracking

- ``isTrackingEnabled``

### User Interface

- ``mediaSelectionMenu(characteristic:)``
- ``playbackSpeedMenu(speeds:)``
- ``standardSettingMenu()``
