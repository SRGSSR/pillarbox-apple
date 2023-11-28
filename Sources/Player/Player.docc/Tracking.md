# Tracking

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: "tracking", alt: "An image of a graph.")
}

Track player items during playback.

## Custom item tracking

Pillarbox makes it possible to easily integrate any kind of tracker, for example to gather analytics, QoS data or to save the current playback position into a history. Proceed as follows to implement your own tracker:

1. Create a new tracker class, say `CustomTracker`, and add conformance to the `PlayerItemTracker` protocol.
2. The `PlayerItemTracker` protocol declares `Configuration` and `Metadata` associated types. If your tracker requires a configuration or metadata related to the item being tracked just create dedicated types which contain all required parameters. Use `Void` for any type that is not required for your tracker.
3. Trackers are automatically instantiated by the item they are associated with. You therefore never instantiate a tracker directly but rather achieve the behavior you need by implementing `PlayerItemTracker` life cycle methods instead:
  a. The `init(configuration:)` initializer is called on your tracker at creation time with the configuration you provided. You can either use this configuration directly to setup your tracker or store it for later use.
  b. The `enable(for:)` method is called when the item to which the tracker is bound becomes the current one.
  c. Metadata updates are automatically reported by the `updateMetadata(with:)` method.
  d. Player property updates are automatically reported by the `updateProperties(with:)` method. Even if your tracker stores the player somehow you should rather use this method as the properties it publishes are guaranteed to be up-to-date. Be careful that properties can change often and that your implementation should be as efficient as possible.
  e. Perform any required cleanup in `disable()`, which is called when the item to which the tracker is bound stops being the current one.
  f. You can perform any necessary final cleanup in `deinit` which is called when the player item and its trackers are discarded.

Once you have a tracker you can attach it to any item. The only requirement is that metadata supplied as part of the asset retrieval process is transformed into metadata required by the tracker. This transformation requires the use of a dedicated adapter, simply created from your custom tracker type with the `adapter(configuration:mapper:)` method. The adapter is also where you can supply any configuration required by your tracker:

```swift
let item = PlayerItem.simple(url: url, metadata: CustomMetadata(), trackerAdapters: [
    CustomTracker.adapter(configuration: configuration) { metadata in
        // Convert metadata into tracker metadata
    }
]
```

Alternative adapter creation methods are available if your tracker has `Void` configuration and / or metadata.

### Remark

Some 3rd party trackers might require low-level access to the `AVPlayer` instance. The `Player` class exposes this player through the `systemPlayer` property. Even though the low-level player is therefore accessible you should never attempt to mutate its state directly. Changes might namely interfere with behavior expected by Pillarbox `Player` class, leading to undefined behavior.
