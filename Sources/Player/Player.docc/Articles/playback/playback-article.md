# Playback

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: playback-card, alt: "A clapperboard image.")
}

Play audio and video content with ease.

## Overview

Use a ``Player`` to manage playback of one or more media items sequentially, and receive automatic updates about playback state changes.

> Important: ``Player`` is built on [AVFoundation](https://developer.apple.com/documentation/avfoundation), meaning it supports media formats like QuickTime movies, MP3 audio files, and audiovisual streams delivered via [HTTP Live Streaming](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices).

## Create a player

You can initialize a player with or without media items. Since ``Player`` conforms to [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject), it should be stored as a [`StateObject`](https://developer.apple.com/documentation/swiftui/stateobject) within a SwiftUI view. This ensures the player’s lifecycle aligns with the view and that UI updates automatically reflect changes in playback state.

@TabNavigator {
    @Tab("No Items") {
        Create an empty player and add items later as needed.

        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player()
        }
        ```
    }

    @Tab("Single Item") {
        Initialize a player with a single media item.

        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player(
                item: .simple(url: URL(string: "https://server.com/stream.m3u8")!)
            )
        }
        ```
    }

    @Tab("Multiple Items") {
        Initialize a player with multiple media items from different sources.

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

> Tip: For more details on observing player state updates, refer to the <doc:state-observation-article> article.

## Configure the player

Customize the player during initialization by providing a ``PlayerConfiguration`` object. Note that configuration settings are immutable after the player is created.

## Load custom content

In scenarios where media URLs are dynamically retrieved (e.g., from a web service), you can create custom player items by following these steps:

1. Write a publisher that fetches the media URL and associated metadata.
2. Map the publisher’s output to an ``Asset`` wrapping the retrieved media URL. If metadata is required (e.g., for <doc:control-center-article> integration or custom tracking), define and attach a suitable ``AssetMetadata`` type and populate it with the retrieved metadata. Refer to the <doc:metadata-article> article for details.
3. Create a ``PlayerItem`` using the publisher, ensuring the initializer accounts for any external parameters the publisher requires.

## Start playback

A newly created player begins in a paused state. To start playback, call ``Player/play()``, typically when the associated user interface appears. Below are examples of basic video playback layouts:

<!-- markdownlint-disable MD034 -->
@TabNavigator {
    @Tab("Default Start Position") {
        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player(
                item: .simple(url: URL(string: "https://server.com/stream.m3u8")!)
            )

            var body: some View {
                VideoView(player: player)
                    .onAppear(perform: player.play)
            }
        }
        ```
    }

    @Tab("Specific Start Position") {
        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player(
                item: .simple(url: URL(string: "https://server.com/stream.m3u8")!) { item in
                    item.seek(at(.init(value: 10, timescale: 1)))
                }
            )

            var body: some View {
                VideoView(player: player)
                    .onAppear(perform: player.play)
            }
        }
        ```
    }
}
<!-- markdownlint-restore -->

## Support background video playback

To support video playback in the background, set the [`audiovisualBackgroundPlaybackPolicy`](https://developer.apple.com/documentation/avfoundation/avplayer/3787548-audiovisualbackgroundplaybackpol) to `.continuesIfPossible`.

However, implementing <doc:picture-in-picture-article> generally offers a better user experience for video content compared to background playback. In such cases, it’s recommended to keep the default `.automatic` setting.
