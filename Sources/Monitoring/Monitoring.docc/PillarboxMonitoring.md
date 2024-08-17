# ``PillarboxMonitoring``

@Metadata {
    @PageColor(red)
}

Monitor playback activity.

## Overview

The PillarboxMonitoring framework provides seamless integration of Pillarbox player with its monitoring platform.

> Important: PillarboxMonitoring sends metrics in a JSON format specific to the Pillarbox monitoring platform. To integrate another monitoring solution you must implement a dedicated `PlayerItemTracker`. Refer to the PillarboxPlayer documentation for more information.

### Monitor content being played

A ``MetricsTracker`` is provided to gather relevant metrics and events during playback, for example:

- How much time is required to start playback from a user perspective.
- Which fatal / non-fatal errors are encountered.
- Which stream quality has been selected by the player.
- How much bandwidth is available.
- ... and many more.

To monitor playback its suffices to attach a ``MetricsTracker`` to a `PlayerItem`, configured with the endpoint where data must be sent. For example:

```swift
let item = PlayerItem.simple(url: URL(string: "https://your.domain.com/content.m3u8", trackerAdapters: [
    MetricsTracker.adapter(
        configuration: .init(serviceUrl: URL(string: "https://your.domain.com/monitoring")!)
    ) { metadata in
        .init(identifier: "your-content-identifier")
    }
])
```

The tracker supports ``MetricsTracker/Metadata`` that can be optionally provided to send additional information about the content being played.

> Tip: Information about the content is usually retrieved by the `PlayerItem` itself and provided automatically to the adapter mapping closure. Refer to PillarboxPlayer documentation for more information.

This is all that is required to monitor playback. Once the item is being played the tracker automatically gathers relevant metrics and sends them to the specified endpoint.

> Important: The data collected by PillarboxMonitoring cannot be used to track users across apps and websites owned by other companies.

## Topics

### Essentials

- ``MetricsTracker``
