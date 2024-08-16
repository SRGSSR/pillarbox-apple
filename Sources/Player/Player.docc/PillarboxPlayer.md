# ``PillarboxPlayer``

@Metadata {
    @PageColor(purple)
}

Create engaging audio and video playback experiences.

## Overview

> Warning: PillarboxPlayer APIs are currently meant to be used from the main thread only. Calling APIs from background threads is not supported and leads to undefined behavior.

The PillarboxPlayer framework provides a complete toolbox to add advanced audiovisual media capabilities to your app.

Play content easily with a ``Player`` and display its content in the standard AVKit user interface with ``SystemVideoView``, or build an entirely custom user interface starting from a simple ``VideoView``. Play any kind of content from any source by implementing your own ``PlayerItem``s and ``Asset``s, no matter where your content comes from or how it must be played. Track playback with your own ``PlayerItemTracker``, whether for analytics or monitoring purposes.

@Image(source: player-intro, alt: "A screenshot of a player user interface")

The PillarboxPlayer framework fully integrates with SwiftUI, embracing its declarative and reactive nature and letting you quickly iterate on your design ideas.

### Featured

@Links(visualStyle: detailedGrid) {
    - <doc:playback>
    - <doc:state-observation>
    - <doc:metadata>
    - <doc:tracking>
    - <doc:metrics>
}

### Asset Loading

@Links(visualStyle: detailedGrid) {
    - <doc:resource-loading>
    - <doc:fairplay-streaming>
}

### System Integration

@Links(visualStyle: detailedGrid) {
    - <doc:airplay>
    - <doc:control-center>
    - <doc:picture-in-picture>
}

## Topics

### Essentials

- <doc:playback>
- <doc:playback-speed>
- <doc:state-observation>
- <doc:subtitles-and-alternative-audio-tracks>

- ``Asset``
- ``MediaSelectionOption``
- ``MediaType``
- ``Player``
- ``PlayerConfiguration``
- ``PlayerItem``
- ``PlayerProperties``
- ``PlaybackState``
- ``Position``
- ``SeekBehavior``
- ``StreamType``

### Metadata

- <doc:metadata>

- ``AssetMetadata``
- ``PlayerMetadata``

### System Integration

- <doc:airplay>
- <doc:control-center>
- <doc:picture-in-picture>

- ``PictureInPicture``
- ``PictureInPictureButton``
- ``PictureInPictureDelegate``
- ``PictureInPicturePersistable``
- ``ProgressTracker``
- ``RoutePickerView``
- ``TrackerAdapter``
- ``VisibilityTracker``

### Customization

- <doc:fairplay-streaming>
- <doc:resource-loading>
- <doc:tracking>

- ``PlayerItemTracker``
- ``ProgressTracker``
- ``TrackerAdapter``
- ``VisibilityTracker``

### User Interface

- <doc:creating-basic-user-interface>

- ``LayoutInfo``
- ``SystemVideoView``
- ``VideoView``

### Monoscopic Video Support

- ``SCNQuaternionForAttitude(_:)``
- ``SCNQuaternionRotate(_:_:_:)``
- ``SCNQuaternionWithAngleAndAxis(_:_:_:_:)``

### Metrics

- <doc:metrics>

- ``Metrics``
- ``MetricsValues``

### Technical Notes

- <doc:stream-encoding-and-packaging-advice>
