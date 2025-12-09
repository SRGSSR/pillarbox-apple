# ``PillarboxPlayer``

@Metadata {
    @PageColor(purple)
}

Craft immersive audiovisual playback experiences.

## Overview

> Warning: PillarboxPlayer APIs are designed for use exclusively on the main thread. Invoking these APIs from background threads is unsupported and may result in unpredictable behavior.

The PillarboxPlayer framework offers a comprehensive suite of tools to seamlessly integrate advanced audiovisual media capabilities into your app:

- Easily play content using a ``Player`` and display it in the standard AVKit user interface with ``SystemVideoView``, or create a fully custom user interface starting with a simple ``VideoView``.
- Support any type of content from any source by implementing custom ``PlayerItem``s and ``Asset``s, regardless of its origin or playback requirements.
- Monitor and analyze playback with your own ``PlayerItemTracker``, tailored for purposes like analytics or performance tracking.

@Image(source: player-intro, alt: "A screenshot of a player user interface")

The PillarboxPlayer framework seamlessly integrates with SwiftUI, leveraging its declarative and reactive design principles to enable rapid iteration and refinement of your ideas.

> Tip: Refer to the Human Interface Guidelines for best practices on integrating [audio](https://developer.apple.com/design/human-interface-guidelines/playing-audio) and [video](https://developer.apple.com/design/human-interface-guidelines/playing-video) experiences within your app.

### Featured

@Links(visualStyle: detailedGrid) {
    - <doc:playback-article>
    - <doc:user-interface-article>
    - <doc:metadata-article>
    - <doc:tracking-article>
    - <doc:metrics-article>
    - <doc:google-cast-article>
    - <doc:state-observation-article>
    - <doc:optimization-article>
}

### Asset Resource Loading

@Links(visualStyle: detailedGrid) {
    - <doc:asset-resource-loading-article>
    - <doc:fairplay-streaming-article>
}

### System Integration

@Links(visualStyle: detailedGrid) {
    - <doc:airplay-article>
    - <doc:control-center-article>
    - <doc:picture-in-picture-article>
}

## Topics

### Essentials

- <doc:playback-article>
- <doc:playback-speed-article>
- <doc:state-observation-article>
- <doc:subtitles-and-alternative-audio-tracks-article>
- <doc:google-cast-article>

- ``Asset``
- ``MediaSelectionOption``
- ``MediaSelectionPreference``
- ``MediaType``
- ``NavigationMode``
- ``PlaybackState``
- ``Player``
- ``PlayerConfiguration``
- ``PlayerItem``
- ``PlayerLimits``
- ``PlayerProperties``
- ``Position``
- ``RepeatMode``
- ``SeekBehavior``
- ``Skip``
- ``StreamType``

### Metadata

- <doc:metadata-article>

- ``AssetMetadata``
- ``Chapter``
- ``EpisodeInformation``
- ``ImageSource``
- ``PlayerMetadata``
- ``TimeRange``

### System Integration

- <doc:airplay-article>
- <doc:control-center-article>
- <doc:picture-in-picture-article>

- ``PictureInPicture``
- ``PictureInPictureButton``
- ``PictureInPictureDelegate``
- ``PictureInPicturePersistable``
- ``RoutePickerView``

### Content Loading

- <doc:fairplay-streaming-article>
- <doc:asset-resource-loading-article>

- ``Asset``
- ``PlaybackConfiguration``
- ``PlayerItem``

### Tracking

- <doc:tracking-article>

- ``PlayerItemTracker``
- ``TrackerAdapter``
- ``TrackerProperties``
- ``TrackingBehavior``

### Metrics

- <doc:metrics-article>

- ``Metrics``
- ``MetricsCollector``
- ``MetricEvent``
- ``MetricsValues``

### User Interface

- <doc:user-interface-article>
- <doc:creating-basic-user-interface>
- <doc:optimization-article>

- ``LayoutInfo``
- ``LazyImage``
- ``LazyUIImage(source:)``
- ``ProgressTracker``
- ``SettingsUpdate``
- ``SkipTracker``
- ``SystemVideoView``
- ``VideoView``
- ``Viewport``
- ``VisibilityTracker``

### Monoscopic Video Support

- ``SCNQuaternionForAttitude(_:)``
- ``SCNQuaternionRotate(_:_:_:)``
- ``SCNQuaternionWithAngleAndAxis(_:_:_:_:)``

### Actions and Menus

- ``Button``
- ``InlinePicker``
- ``Menu``
- ``Option``
- ``Picker``
- ``Section``
- ``Toggle``

### Domain-specific Language

- ``ButtonInContextualActions``
- ``ButtonInInfoViewActions``
- ``ButtonInMenu``
- ``ButtonInSection``
- ``ButtonInTransportBar``
- ``ContextualActionsBody``
- ``ContextualActionsBodyNotSupported``
- ``ContextualActionsContent``
- ``ContextualActionsContentBuilder``
- ``ContextualActionsElement``
- ``InfoViewActionsBody``
- ``InfoViewActionsBodyNotSupported``
- ``InfoViewActionsContent``
- ``InfoViewActionsContentBuilder``
- ``InfoViewActionsElement``
- ``InlinePicker``
- ``InlinePickerBody``
- ``InlinePickerBodyNotSupported``
- ``InlinePickerContent``
- ``InlinePickerContentBuilder``
- ``InlinePickerElement``
- ``InlinePickerInMenu``
- ``MenuBody``
- ``MenuBodyNotSupported``
- ``MenuContent``
- ``MenuContentBuilder``
- ``MenuElement``
- ``MenuInMenu``
- ``MenuInSection``
- ``MenuInTransportBar``
- ``OptionInInlinePicker``
- ``OptionInPicker``
- ``OptionInPickerSection``
- ``PickerBody``
- ``PickerContent``
- ``PickerContentBuilder``
- ``PickerElement``
- ``PickerBodyNotSupported``
- ``PickerInMenu``
- ``PickerInSection``
- ``PickerInTransportBar``
- ``PickerSectionBody``
- ``PickerSectionBodyNotSupported``
- ``PickerSectionContent``
- ``PickerSectionContentBuilder``
- ``PickerSectionElement``
- ``SectionBody``
- ``SectionBodyNotSupported``
- ``SectionContent``
- ``SectionContentBuilder``
- ``SectionInMenu``
- ``SectionInPicker``
- ``SectionElement``
- ``ToggleInMenu``
- ``ToggleInSection``
- ``ToggleInTransportBar``
- ``TransportBarBody``
- ``TransportBarBodyNotSupported``
- ``TransportBarContent``
- ``TransportBarContentBuilder``
- ``TransportBarElement``

### Technical Notes

- <doc:stream-encoding-and-packaging-advice-article>
