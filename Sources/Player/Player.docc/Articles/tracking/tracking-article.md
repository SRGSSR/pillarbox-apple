# Tracking

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: tracking-card, alt: "An image depicting a graph.")
}

Monitor and analyze playback activity.

## Overview

The ``PillarboxPlayer`` framework provides tools to track items during playback, making it ideal for gathering analytics, monitoring Quality of Experience (QoE) and Quality of Service (QoS), or storing playback positions in a local history.

To implement a tracker, define the data requirements and lifecycle of your tracker by creating a new class type that conforms to the ``PlayerItemTracker`` protocol. The following sections guide you through the process.

### Design tracker data

The ``PlayerItemTracker`` protocol uses two associated types to define the data required by your tracker:

- ``PlayerItemTracker/Metadata`` represents metadata required by the tracker. This updates whenever a tracked player item delivers a new asset.
- ``PlayerItemTracker/Configuration`` represents configuration parameters provided during tracker creation. These parameters are independent of the player item itself.

> Note: Use Void for either type if it is not applicable to your tracker.

### Implement the tracker lifecycle

After defining the associated types, implement the tracker lifecycle methods to manage its behavior:

1. ``PlayerItemTracker/init(configuration:queue:)`` is called when the tracker and its item are created. This initializer receives the configuration instance defined earlier.
2. ``PlayerItemTracker/enable(for:)`` is called when the associated item becomes active. Use this method to integrate with the player, possibly leveraging the provided `AVPlayer` instance for third-party SDK integration if needed.
3. ``PlayerItemTracker/updateMetadata(to:)`` is called when metadata is delivered. The method receives an instance of the tracker-specific metadata type defined earlier.
4. ``PlayerItemTracker/updateProperties(to:)`` is called to reflect changes to player properties. As properties can update frequently, ensure this implementation is highly efficient.
5. ``PlayerItemTracker/updateMetricEvents(to:)`` is called when processing ``MetricEvent`` instances as they are received.
6. ``PlayerItemTracker/disable(with:)`` is called to clean up resources when the player item is no longer active. Use the provided properties to extract final player state information.
7. Use `deinit` to perform any necessary cleanup when the tracker and its item are discarded.

> Important: A tracker is reused if the same item is replayed. Ensure that any state is properly initialized in ``PlayerItemTracker/enable(for:)`` and reset in ``PlayerItemTracker/disable(with:)``.

### Attach a tracker to an item

To attach a tracker, transform the ``AssetMetadata`` retrieved during ``Asset`` creation into the ``PlayerItemTracker/Metadata`` type defined for your tracker. Use an adapter for this transformation, which you can create with the ``PlayerItemTracker/adapter(configuration:behavior:mapper:)`` method:

```swift
let item = PlayerItem.simple(url: url, metadata: CustomMetadata(), trackerAdapters: [
    CustomTracker.adapter(configuration: configuration) { metadata in
        // Convert `CustomMetadata` into tracker metadata
    }
]
```

You can also:

- Use alternative adapter creation methods if your tracker’s configuration or metadata is `Void`.
- Enable or disable tracking globally with the ``Player/isTrackingEnabled`` property. To enforce tracking regardless of this setting, set the adapter behavior to ``TrackingBehavior/mandatory`` during its creation.

### Associate a session identifier

Trackers can assign an optional session identifier to playback activity. Session identifiers are particularly useful for matching locally collected data with external services:

1. Implement ``PlayerItemTracker/sessionIdentifier-329qf`` to provide a unique identifier for each playback session. Consider creating a new identifier for every playback attempt.
2. Retrieve session identifiers in use with the ``Player/currentSessionIdentifiers(trackedBy:)`` method. Use this for debugging, support, or integration with external systems. For example, you can display identifiers alongside error messages, copy them to the clipboard, or include them in automated emails to support teams.
