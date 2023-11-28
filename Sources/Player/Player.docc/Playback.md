# Playback

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: "pipes", alt: "An image depicting pipes.")
}

Play audio and video content.  

## Create a Player

In your SwiftUI view simply instantiate and store a ``Player`` as a @StateObject.

@TabNavigator {
    @Tab("Empty") {
        You can create an empty player and update its item list at a later time.

        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player()
        }
        ```
    }

    @Tab("Single item") {
        You can provide one player item at construction time.

        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player(item:
                .simple(url: URL(string: "https://server.com/stream.m3u8")!)
            )
        }
        ```
    }

    @Tab("Several items") {
        You can provide several player items at construction time, possibly from various sources.

        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player(items: [
                .simple(url: URL(string: "https://server.com/stream_1.m3u8")!),
                .simple(url: URL(string: "https://server.com/stream_2.m3u8")!)
            ])
        }
        ```
    }
}

## Custom player items

Pillarbox provides a way to retrieve a content URL and related metadata from any service:

1. Write a publisher which retrieves the URL to be played as well as any required metadata you might need.
2. Map the result of your publisher into an ``Asset``. Three categories of assets are provided:
   - Simple assets which can be played directly.
   - Custom assets which require a custom resource loader delegate.
   - Encrypted assets which require a FairPlay content key session delegate.
3. If you want to provide asset metadata, most notably for tracker integration (see next section), just define a corresponding type and associate an instance with your asset.
4. Create a ``PlayerItem`` with the corresponding initializer taking a publisher as argument.

The resulting player item can then be played in a Pillarbox ``Player`` instance. It can also be shared so that other products can easily play content you provide.

## Background video playback

``Player`` can be enabled for background video playback using `audiovisualBackgroundPlaybackPolicy`. For SRG SSR content, though, your application must not implement background video playback to avoid issues with comScore measurements. Please implement proper Picture in Picture support instead.
