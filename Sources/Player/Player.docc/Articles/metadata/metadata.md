# Metadata

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: metadata-card, alt: "An image depicting a database.")
}

Associate metadata with the content being played.

## Overview

A ``PlayerItem`` is responsible of delivering a playable ``Asset``, which can optionally be attached metadata describing the content being played.

Metadata serves two purposes:

- A ``Player`` automatically retrieves and publishes standard ``PlayerMetadata`` about its current item. This possibly includes a title, a subtitle, an artwork image or chapters, for example. To provide standard player metadata an asset metadata must conform to the ``AssetMetadata`` protocol.
- Metadata associated with an asset is provided as is to any ``TrackerAdapter`` associated with a ``PlayerItem``. This makes it possible to map metadata to the input expected from a concrete ``PlayerItemTracker`` implementation. For more information please refer to the <doc:tracking> article.

Standard metadata can be used by player user interfaces. It is also used to consistently update information displayed in the Control Center.

## Define player metadata

Suppose you retrieve metadata about content being played from some web service in the following format:

```swift
struct Media {
    let name: String
    let show: String?
    let date: Date
    let artworkUrl: URL
    let streamUrl: URL
}
```

To be able to associate this metadata with an ``Asset`` it must conform to ``AssetMetadata``. This lets you define which standard ``PlayerMetadata`` must be extracted and published by the player once it plays this item, for example:

```swift
extension Media: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: show, subtitle: name, imageSource: .url(artworkUrl))
    }
}
```

Images are provided as ``ImageSource``, either as a URL or as a `UIImage`.

> Note: To avoid wasting resources images are only loaded when actually needed.

### Chapters

If your metadata provides markers into the content, as well as metadata describing them, you should build a corresponding ``Chapter`` list and provide it to the  ``PlayerMetadata`` via its ``PlayerMetadata/chapters`` parameter.

On iOS chapters can be displayed by custom user interfaces. This can serve display purposes or let you implement alternative ways of navigating the content. On tvOS chapters are automatically displayed in the standard playback user interface info panel.

### Time ranges

In addition your metadata might include information about remarkable time ranges within the content. Standard player metadata currently supports:

- Opening and closing credits, during which custom user interfaces might want to adjust their presentation (e.g. add a skip button).
- Blocked time ranges which should never be playable. A ``Player`` automatically skips blocked time ranges during playback and prevents seek attempts into them.

If this makes sense for your content you can build a corresponding ``TimeRange`` list and provide it to the  ``PlayerMetadata`` via its ``PlayerMetadata/timeRanges`` parameter.

> Tip: On tvOS you might want to use `SystemVideoView/contextualActions(_:)` to associate contextual actions during opening or closing credits.

## Display metadata in a player user interface

``PlayerMetadata`` associated with the item currently being played is automatically made available by a ``Player`` through its ``Player/metadata`` published property.

On iOS you can use this metadata to display the title, subtitle and artwork associated with the content being played. You can also display associated chapters or adjust your user interface during time range traversal.

To display images you must use a ``LazyImage`` instantiated with an ``ImageSource``. This ensures that images are only retrieved when actually required.

> Tip: When using ``SystemVideoView``, either on iOS or tvOS, most metadata is automatically displayed.
