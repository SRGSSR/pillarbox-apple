
# ``PillarboxCoreBusiness``

@Metadata {
    @PageColor(yellow)
}

Play SRG SSR content with the PillarboxPlayer framework.

## Overview

The PillarboxCoreBusiness framework offers standard SRG SSR business integration, most notably:

- **Player items** designed for loading content provided by the official SRG SSR backend, known as the Integration Layer.
- **Streaming analytics** that adhere to SRG SSR requirements.

> Important: Streaming measurements are automatically captured when playing SRG SSR content using the PillarboxCoreBusiness framework. Ensure that tracking is properly set up beforehand. Refer to the PillarboxAnalytics documentation for more details.

### Play SRG SSR content

To play SRG SSR content, create a `PlayerItem` using ``PillarboxPlayer/PlayerItem/urn(_:server:trackerAdapters:configuration:)``, and pass the content URN as a parameter. Then load this `PlayerItem` into a `Player` instance.

You can specify a different server or add custom tracker adapters. Standard SRG SSR trackers cannot be disabled.

> Tip: Tracker adapters receive a ``MediaMetadata`` instance as input. If your tracker requires additional data that is not currently available, please submit a corresponding [feature request](https://github.com/SRGSSR/pillarbox-apple/issues/new?assignees=&labels=enhancement%2Ctriage&projects=&template=feature_request.yml).

### Avoid background playback

comScore regulations prohibit video measurements without a visible video view on the screen.

Do not enable background video playback using `audiovisualBackgroundPlaybackPolicy` on a player loaded with SRG SSR content. Instead, implement proper Picture in Picture (PiP) support to ensure compliance.

## Topics

### Content

- ``PillarboxPlayer/PlayerItem``
- ``Server``

### Metadata

- ``MediaComposition``
- ``MediaMetadata``
