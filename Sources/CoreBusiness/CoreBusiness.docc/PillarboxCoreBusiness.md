
# ``PillarboxCoreBusiness``

@Metadata {
    @PageColor(yellow)
}

Play SRG SSR content with the PillarboxPlayer framework.

## Overview

The PillarboxCoreBusiness framework provides standard SRG SSR business integration:

- Player items to load content delivered by the Integration Layer.
- Streaming analytics according to SRG SSR requirements.

> Important: Streaming measurements are automatically collected when playing SRG SSR content using the PillarboxCoreBusiness framework. Just ensure that tracking has been properly setup first. Please refer to the Analytics documentation for more information.

### Play SRG SSR content

To play an SRG SSR content simply create a `PlayerItem` with ``PillarboxPlayer/PlayerItem/urn(_:server:trackerAdapters:configuration:)``, passing the URN of the content as parameter. Then load it into a `Player`.

You can optionally change the server or add additional custom player item trackers. Standard SRG SSR trackers cannot be disabled.

> Tip: Tracker adapters receive standard a ``MediaMetadata`` instance as parameter. If data your tracker needs is not available please file a corresponding [issue](https://github.com/SRGSSR/pillarbox-apple/issues/new?assignees=&labels=enhancement%2Ctriage&projects=&template=feature_request.yaml) so that we can parse it.

### Avoid background playback

comScore forbids video measurements without a video view being actually visible on screen.

You must therefore never enable background video playback with `Player/audiovisualBackgroundPlaybackPolicy` when playing SRG SSR content. Implement proper Picture in Picture support instead.

## Topics

### Content

- ``PillarboxPlayer/PlayerItem``
- ``Server``

### Metadata

- ``MediaComposition``
- ``MediaMetadata``
