# Playback

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: "pipes", alt: "An image depicting pipes.")
}

Play audio and video content.

You use the player to manage the playback of a media item, for example starting and stopping playback, or even seeking to a particular time.
A player can manage the playback of a several media item from various locations to play sequentially.

- Important: Since the player is based on [AVFoundation](https://developer.apple.com/documentation/avfoundation), it can only read QuickTime movies, MP3 audio files, and audiovisual media served via HTTP Live Streaming.

## Create a Player

In your [SwiftUI](https://developer.apple.com/documentation/swiftui) view simply instantiate and store a ``Player/Player`` as a [@StateObject](https://developer.apple.com/documentation/swiftui/stateobject).

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

## Configuration

The player can be customized during the instantiation phase by providing a dedicated ``PlayerConfiguration`` object.
It is crucial to note that the configuration is set only at the time of instantiation and remains constant throughout the player's entire lifecycle.

- Tip: If you wish to apply a new configuration, you must create a new player instance with a newly created configuration.

## Custom player items

The previous examples use a ``PlayerItem/simple(url:metadata:trackerAdapters:configuration:)`` player item, but you can create your own.

Here is how to retrieve a content URL and related metadata from any service:

1. Write a publisher which retrieves the URL to be played as well as any required metadata you might need.
2. Map the result of your publisher into an ``Asset``.
3. If you want to provide asset metadata, most notably for tracker integration (see next section), just define a corresponding type and associate an instance with your asset.
4. Create a ``PlayerItem`` with the corresponding initializer taking a publisher as argument.

The resulting player item can then be played in the ``Player/Player`` instance. It can also be shared so that other products can easily play content you provide.

## Background video playback

The player offers the capability for background video playback through the use of the ``Player/Player/audiovisualBackgroundPlaybackPolicy`` property.
In other words, you can ask your player on how to behave when the app goes into the background.

@TabNavigator {
    @Tab("Automatic") {
        Indicates that the system is free to decide. This is the default policy.
        ```swift
        let player = Player()
        player.audiovisualBackgroundPlaybackPolicy = .automatic

        ```
    }
    @Tab("Pauses") {
        Indicates that the player must be paused on going to background.
        ```swift
        let player = Player()
        player.audiovisualBackgroundPlaybackPolicy = .pauses

        ```
    }
    @Tab("Continues if possible") {
        Indicates that the player continues to play if possible in background.
        ```swift
        let player = Player()
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible

        ```
    }
}

## Playback speed

The player also allows you to control the playback speed of the stream.
You can adjust the speed at which the stream is played using the ``Player/Player/setDesiredPlaybackSpeed(_:)`` method or by using ``Player/Player/playbackSpeed`` property.

@TabNavigator {
    @Tab("Method") {
        ```swift
        let player = Player()
        player.setDesiredSpeed(2)

        ```
    }
    @Tab("Property") {
        ```swift
        @ObservedObject var player: Player
        
        Picker("Playback Speed", selection: player.playbackSpeed) {
            ForEach([0.25, 0.75, 1, 1.5. 2], id: \.self) { speed in
                Text("\(speed, specifier: "%g×")").tag(speed)
            }
        }
        .pickerStyle(.inline)

        ```
    }
}
