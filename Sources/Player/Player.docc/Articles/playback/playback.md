# Playback

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: playback-card, alt: "An image depicting a clapperboard.")
}

Play audio and video content.

## Overview

Use a ``Player`` to play of one or several items sequentially and be automatically notified about the state of playback.

> Important: ``Player`` is implemented using [AVFoundation](https://developer.apple.com/documentation/avfoundation) and can therefore only read media like QuickTime movies, MP3 audio files or audiovisual media served via [HTTP Live Streaming](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices).

## Create a Player

You create a player with or without associated items to be played. Since ``Player`` is an [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject) you usually store an instance as a [`StateObject`](https://developer.apple.com/documentation/swiftui/stateobject) belonging to some [SwiftUI](https://developer.apple.com/documentation/swiftui) view. This not only ensures that the instance remains available for the duration of the view, but also that the view body is automatically updated when the state of the player changes.

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
        You can provide a single player item at construction time.

        ```swift
        struct PlayerView: View {
            @StateObject private var player = Player(
                item: .simple(url: URL(string: "https://server.com/stream.m3u8")!)
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

> Tip: Please read <doc:state-observation> for more information about how player updates are published.

## Configure the player

The player can be customized during the instantiation phase by providing a dedicated ``PlayerConfiguration`` object. It is important to note that the configuration is set only at the time of instantiation and remains constant throughout the player's entire life cycle.

## Load custom content

The above examples use ``PlayerItem/simple(url:metadata:trackerAdapters:configuration:)`` player items that simply play the provided URLs. In general, though, the URL of the content to be played is not known beforehand and likely retrieved from some kind of web service.

You can create a player item that loads content in a custom way as follows:

1. Write a publisher which retrieves the URL to be played as well as any required metadata you might need. This publisher likely requires some external parameters to be provided, for example a content identifier.
2. Map the result of your publisher to an ``Asset``. If you want to provide asset metadata, most notably for <doc:control-center> integration or custom <doc:tracking>, you must define a corresponding type and associate an instance with your asset. Please refer to the <doc:metadata> article for more information.
3. Create a ``PlayerItem`` with the corresponding initializer taking a publisher as argument. Your item initializer signature should likely reflect the external parameters required by your publisher.

The resulting player item can then be played with ``Player`` instance, possibly mixed with content from other sources.

## Start playback

A player loaded with content starts in a paused state. To actually start playback you have to call ``Player/play()``, usually when the associated view appears. For example a very basic layout able to display video content would look like:

<!-- markdownlint-disable MD034 -->
@TabNavigator {
    @Tab("Start at the default position") {
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

    @Tab("Start at a given position") {
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

## Play video in the background

The ``PlayerConfiguration`` lets you customize how video playback behaves when the app goes into the background. The default [`audiovisualBackgroundPlaybackPolicy`](https://developer.apple.com/documentation/avfoundation/avplayer/3787548-audiovisualbackgroundplaybackpol) behavior pauses video playback in background but you can also choose to continue if possible.

> Tip: If your app plays video content <doc:picture-in-picture> provides a better experience than background video playback and should generally be implemented instead. You can stick to the default background video policy in this case.
