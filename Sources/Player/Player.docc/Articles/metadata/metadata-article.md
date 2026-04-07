# Metadata

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: metadata-card, alt: "An image depicting a database.")
}

Associate metadata with the content being played.

## Overview

Assets loaded into a player typically include additional metadata such as a title, subtitle, artwork, or chapter information. This metadata serves two primary purposes:

1. When mapped to ``PlayerMetadata``, a ``Player`` can automatically publish metadata associated with the current item. This enables you to display contextual information in custom user interfaces. Player metadata is also automatically surfaced in the Control Center. For more details, see <doc:control-center-article>.
2. Asset metadata is also forwarded as-is to any ``TrackerAdapter`` attached to a ``PlayerItem``. This allows you to transform and adapt metadata to match the input requirements of a specific ``PlayerItemTracker`` implementation. For more details, see <doc:tracking-article>.

For additional information about asset loading in general, refer to <doc:playback-article>.

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

When implementing an ``AssetLoader``, use ``AssetLoader/playerMetadata(from:)`` to transform this model into a ``PlayerMetadata`` instance that the player can understand and expose:

```swift
enum MediaAssetLoader: AssetLoader {
    struct Input {
        // ...
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<Media>, Error> {
        // ...
    }

    static func playerMetadata(from metadata: Media) -> PlayerMetadata {
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

> Tip: On tvOS, use `SystemVideoView/contextualActions(_:)` to link contextual actions during opening or closing credits.

## Display metadata in a player user interface

A ``Player`` automatically publishes ``PlayerMetadata`` for the current item via its ``Player/metadata`` property.

On iOS, you can display the title, subtitle, and artwork for the content being played. You can also show chapters or adjust your interface during time range traversal.

To display images, use a ``LazyImage`` initialized with an ``ImageSource``. This ensures images are retrieved only when necessary.

> Tip: With ``SystemVideoView`` on iOS or tvOS, most metadata is automatically displayed.
