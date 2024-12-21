# Metadata

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: metadata-card, alt: "An image depicting a database.")
}

Associate metadata with the content being played.

## Overview

A ``PlayerItem`` is responsible for delivering a playable ``Asset``, which can optionally include metadata describing the content being played.

Metadata serves two key purposes:

1. A ``Player`` automatically retrieves and publishes standard ``PlayerMetadata`` about its current item. This may include a title, subtitle, artwork image, or chapters. To enable this, the asset’s metadata must conform to the ``AssetMetadata`` protocol.
2. Metadata associated with an asset is passed as-is to any ``TrackerAdapter`` linked to a ``PlayerItem``. This allows metadata to be mapped to the expected input of a specific ``PlayerItemTracker`` implementation. For more details, refer to the <doc:tracking-article> article.

Standard metadata can be used when designing custom player user interfaces and ensures consistent information display in the Control Center.

## Define player metadata

Suppose you retrieve metadata about the content from a web service in the following format:

```swift
struct Media {
    let name: String
    let show: String?
    let date: Date
    let artworkUrl: URL
    let streamUrl: URL
}
```

To associate this metadata with an ``Asset``, it must conform to ``AssetMetadata``. This enables the player to extract and publish the standard ``PlayerMetadata`` for the item, such as:

```swift
extension Media: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: show, subtitle: name, imageSource: .url(artworkUrl))
    }
}
```

Images are provided as ``ImageSource``, either as a URL or a `UIImage`. This abstraction ensures that images are loaded only when needed to optimize resource usage.

### Chapters

If your metadata includes markers within the content, you can associate a ``Chapter`` list with the ``PlayerMetadata``:

- On iOS, chapters can be displayed in custom user interfaces, enabling better navigation and display.
- On tvOS, chapters are automatically shown in the standard playback interface info panel.

### Time ranges

Your metadata might also describe notable time ranges, such as:

- **Opening and Closing Credits:** Custom UIs might adjust their presentation (e.g., adding a skip button) during credits.
- **Blocked Time Ranges:** Segments that should be unplayable. A ``Player`` automatically skips these during playback and prevents seeking into them.

To associate time ranges with your metadata, build a ``TimeRange`` list and provide it to the ``PlayerMetadata`` via its ``PlayerMetadata/timeRanges`` parameter.

> Tip: On tvOS, use  `SystemVideoView/contextualActions(_:)` to link contextual actions during opening or closing credits.

## Display metadata in a player user interface

A ``Player`` automatically publishes ``PlayerMetadata`` for the current item via its ``Player/metadata`` property.

On iOS, you can display the title, subtitle, and artwork for the content being played. You can also show chapters or adjust your interface during time range traversal.

To display images, use a ``LazyImage`` initialized with an ``ImageSource``. This ensures images are retrieved only when necessary.

> Tip: With ``SystemVideoView`` on iOS or tvOS, most metadata is automatically displayed.
