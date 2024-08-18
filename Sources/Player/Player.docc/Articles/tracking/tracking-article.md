# Tracking

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: tracking-card, alt: "An image depicting a graph.")
}

Track player items during playback.

## Overview

The PillarboxPlayer framework offers a way to track an item during playback. This mechanism is mostly useful to gather analytics, perform Quality of Experience (QoE) and Quality of Service (QoS) monitoring or save the current playback position into a local history, for example.

You define which data is required by a tracker as well as its life cycle by creating a new class type and conforming it to the ``PlayerItemTracker`` protocol. This can be achieved in a few steps discussed below.

### Design data required by your tracker

The ``PlayerItemTracker`` protocol declares two associated types which you should define according to your tracker needs, likely using simple structs:

- ``PlayerItemTracker/Metadata`` represents metadata required by the tracker. Metadata is updated each time an asset is delivered by the tracked ``PlayerItem``.
- ``PlayerItemTracker/Configuration`` represents configuration parameters required by the tracker. These parameters are provided at creation time and do not depend on the item itself.

> Note: Use `Void` if any of these types is not relevant for your tracker.

### Respond to tracker life cycle events

Once types associated with an item tracker have been defined, start implementing the tracker life cycle itself:

1. ``PlayerItemTracker/init(configuration:)`` is called when the tracker and its item are created. This initializer receives an instance of the configuration type you defined above.
2. ``PlayerItemTracker/enable(for:)`` is called when the associated item becomes the current one. You can perform player-related setup in this method. An `AVPlayer` instance is provided as parameter and can be used for integration with 3rd party SDK requiring it.
3. ``PlayerItemTracker/updateMetadata(to:)`` is called when metadata is updated for the player item, following retrieval of a new ``Asset``. The method receives an instance of the metadata type you defined above.
4. ``PlayerItemTracker/updateProperties(to:)`` is called when player properties change. Be careful that properties can change often and that your implementation should be as efficient as possible.
5. ``PlayerItemTracker/updateMetricEvents(to:)`` is called when a new ``MetricEvent`` has been received.
6. ``PlayerItemTracker/disable(with:)`` is called when the player item stops being the current one. Your implementation should clean up resources acquired in ``PlayerItemTracker/enable(for:)``. The provided properties can be used to extract player state information at the end of playback.
7. Since item trackers are required to be classes you can use `deinit` to perform any necessary final cleanup when the tracker and its item are discarded.

> Important: The tracker associated with an item is reused when the same item is played again. If the tracker stores any state, ensure that the state is properly initialized or cleaned up when the tracker is enabled or disabled.

### Attach a tracker to an item

Once you have a tracker you can attach it to any item. The only requirement is that ``AssetMetadata`` supplied as part of the ``Asset`` retrieval process is transformed into ``PlayerItemTracker/Metadata`` required by the tracker.

> Tip: More information about <doc:metadata-article> is available from the dedicated article.

This transformation requires the use of a dedicated adapter, simply created from your custom tracker type using the ``PlayerItemTracker/adapter(configuration:behavior:mapper:)`` method. The adapter is also where you can supply any configuration required by your tracker:

```swift
let item = PlayerItem.simple(url: url, metadata: CustomMetadata(), trackerAdapters: [
    CustomTracker.adapter(configuration: configuration) { metadata in
        // Convert `CustomMetadata` into tracker metadata
    }
]
```

Note that alternative adapter creation methods are available if your tracker has `Void` configuration and / or metadata.

> Tip: You can enable or disable trackers with the ``Player/isTrackingEnabled`` player property. Trackers ignore this setting if their behavior is set to to ``TrackingBehavior/mandatory`` when creating the associated adapter with ``PlayerItemTracker/adapter(configuration:behavior:mapper:)``.

### Associate a session identifier

A ``PlayerItemTracker`` can associate an optional ``PlayerItemTracker/sessionIdentifier-329qf`` with content being played.

Session identifiers are useful for trackers collecting data and sending it to an external service. In such cases you might namely want to match data received remotely with a local session. If this is the case:

1. Implement ``PlayerItemTracker/sessionIdentifier-329qf`` and return an identifier for the current session. You might want to associate a different session with each playback attempt.
2. When you need to obtain the list of identifiers in use for some type of tracker, call ``Player/currentSessionIdentifiers(trackedBy:)``, passing it the tracker type. How you make it possible to extract session identifiers client-side is entirely up to you. You might want to display them alongside error messages, automatically capture them into the clipboard, or add them to an email sent to some support recipient address, for example.
