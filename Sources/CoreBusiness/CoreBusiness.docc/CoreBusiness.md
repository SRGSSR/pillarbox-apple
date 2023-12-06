
# ``CoreBusiness``

@Metadata {
    @PageColor(yellow)
}

Play SRG SSR content with the Player framework.

## Overview

The CoreBusiness framework provides standard SRG SSR business integration:

- Player items to load content delivered by the Integration Layer.
- Streaming analytics according to SRG SSR requirements.

### Play SRG SSR content

To play an SRG SSR content simply create a `PlayerItem` with ``Player/PlayerItem/urn(_:server:trackerAdapters:)``, passing the URN of the content as parameter. Then load it into a `Player`.

You can optionally change the server or add additional custom player item trackers. Standard SRG SSR trackers cannot be disabled.

> Tip: Tracker adapters receive standard a ``MediaMetadata`` instance as parameter. If data your tracker needs is not available please file a corresponding [issue](https://github.com/SRGSSR/pillarbox-apple/issues/new?assignees=&labels=enhancement%2Ctriage&projects=&template=feature_request.yaml) so that we can parse it.

### Avoid background playback

comScore forbids video measurements without a video view being actually visible on screen.

You must therefore never enable background video playback with `Player/audiovisualBackgroundPlaybackPolicy` when playing SRG SSR content. Implement proper Picture in Picture support instead.
