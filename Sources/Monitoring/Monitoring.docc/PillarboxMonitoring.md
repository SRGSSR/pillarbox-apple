# ``PillarboxMonitoring``

@Metadata {
    @PageColor(red)
}

Monitor playback activity.

## Overview

The PillarboxMonitoring framework enables seamless integration of the Pillarbox player with its monitoring platform, ensuring detailed playback playback metrics and events, such as:

- Time taken to start playback from the user’s perspective.
- Fatal and non-fatal errors encountered.
- Stream quality selected by the player.
- Available bandwidth.

> Important: PillarboxMonitoring sends metrics in a JSON format specific to the Pillarbox monitoring platform. If you need to integrate a different monitoring solution, you must implement a custom `PlayerItemTracker` in place of PillarboxMonitoring. Refer to the PillarboxPlayer documentation for details.

### Monitor content being played

To monitor playback, attach a ``MetricsTracker`` to a `PlayerItem`, configured with the endpoint for sending data. For example:

```swift
let item = PlayerItem.simple(url: URL(string: "https://your.domain.com/content.m3u8")!, trackerAdapters: [
    MetricsTracker.adapter(
        configuration: .init(serviceUrl: URL(string: "https://your.domain.com/monitoring")!)
    ) { metadata in
        .init(identifier: "your-content-identifier")
    }
])
```

The ``MetricsTracker`` can optionally accept ``MetricsTracker/Metadata``, allowing you to provide additional information about the content being played.

Once playback begins, the tracker automatically collects relevant metrics and sends them to the configured endpoint.

> Important: Data collected by PillarboxMonitoring is strictly limited to playback monitoring and will never be used to track users across apps or websites owned by other companies.

## Topics

### Essentials

- ``MetricsTracker``
