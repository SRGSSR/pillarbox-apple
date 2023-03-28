# Getting started

> 🚧 This documentation is a work-in-progress and focuses on basic Pillarbox integration only.

The following guide describes basic integration of the Pillarbox player into an application. This guide assumes SwiftUI usage, though Pillarbox can also be integrated into UIKit-based applications.

## Imports

To instantiate the player you must import the associated package first:

```swift
import Player
```

This package also provides basic user components to build a player user interface. To play SRG SSR content you must in addition import our `CoreBusiness` package:

```swift
import CoreBusiness
```

### Remark

If you need to access `AVFoundation` APIs please import the associated framework directly, as Pillarbox dependencies are not automatically pulled when importing one of its packages.

## Player instantiation

In your SwiftUI view simply instantiate and store a `Player` as a `@StateObject`. You can provide one or several player items at construction time, possibly from various sources:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(items: [
        .simple(url: URL(string: "https://server.com/stream.m3u8")!),
        .urn("urn:rts:video:13444333")
    ])

    // ...
}
```

You can also create an empty `Player` and update its item list at a later time.

## Video view

Once you have a player you can display its contents in a `VideoView`, provided you are playing video content of course. Since the player is initialized in a paused state you probably want to call `play()` when the view appears:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(items: [
        .simple(url: URL(string: "https://server.com/stream.m3u8")!),
        .urn("urn:rts:video:13444333")
    ])

    var body: some View {
        VideoView(player: player)
            .onAppear(perform: player.play)
    }
}
```

A system default playback user experience is provided as well. Just use `SystemVideoView` instead of `VideoView`.

## User interface visibility management (iOS)

A player usually responds to user interaction in a standard way:

- Controls are toggled on or off when the user taps the player area.
- Controls are automatically hidden after some delay during playback. Auto hide must only occur as long as the user is not actively interacting with the player, though, for example if controls contain a slider or buttons.

Pillarbox provides `VisibilityTracker` to make implementing this standard behavior as straightforward as possible. This observable object exposes a `isUserInterfaceHidden` read-only property which advises whether a player user interface should be hidden or not.

### Visibility tracking

We want to expand our above example by adding a controls overlay containing a playback button. We can use a visibility tracker to manage playback button visibility so that the button is automatically hidden after a while. Note that the visibility tracker must be explicitly bound to the player using the dedicated `bind(_:to:)` modifier:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(items: [
        .simple(url: URL(string: "https://server.com/stream.m3u8")!),
        .urn("urn:rts:video:13444333")
    ])

    @StateObject private var visibilityTracker = VisibilityTracker()

    var body: some View {
        ZStack {
            VideoView(player: player)
            controls()
        }
        .animation(.linear, value: visibilityTracker.isUserInterfaceHidden)
        .onTapGesture(perform: visibilityTracker.toggle)
        .onAppear(perform: player.play)
        .bind(visibilityTracker, to: player)
    }

    @ViewBuilder
    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.3)
            Button(action: player.togglePlayPause) {
                Image(systemName: playbackButtonImageName)
                    .resizable()
                    .tint(.white)
            }
            .aspectRatio(contentMode: .fit)
            .frame(height: 90)
        }
        .opacity(visibilityTracker.isUserInterfaceHidden ? 0 : 1)
    }

    private var playbackButtonImageName: String {
        switch player.playbackState {
        case .playing:
            return "pause.circle.fill"
        default:
            return "play.circle.fill"
        }
    }
}
```

We also bound an animation to `visibilityTracker.isUserInterfaceHidden` changes so that controls fade in and out.

### Interaction tracking

We want to ensure that controls stay visible if the user is somehow interacting with them. This behavior can simply be achieved by wrapping the player area where user interaction must be tracked with an `InteractionView`. The interaction view calls an action block when any touch is detected within its frame. In our case we simply reset the auto hide mechanism whenever this happens:

```swift
struct PlayerView: View {
    // ...

    var body: some View {
        InteractionView(action: visibilityTracker.reset) {
            ZStack {
                VideoView(player: player)
                controls()
            }
            .animation(.linear, value: visibilityTracker.isUserInterfaceHidden)
            .onTapGesture(perform: visibilityTracker.toggle)
        }
        .onAppear(perform: player.play)
        .bind(visibilityTracker, to: player)
    }
}
```

## Custom view layouts

Pillarbox currently does not provide any standard playback view you can use but you can build one yourself. Since `Player` is an `ObservableObject`, though, implementation of a playback view can be easily achieved in the same was as for any usual SwiftUI layout.

When significant changes occur within the player (e.g. state or buffering updates) the body of any SwiftUI view observing the player is evaluated again. You can use states available from `Player` to update your user interface accordingly, e.g. to display a playback button with an appropriate icon depending on whether the player is playing or not.

### Optimizing layout refreshes

Periodic time updates are not published automatically by a `Player`. If you want to respond to time updates you must instantiate a `ProgressTracker`. This observable object both lets you observe time updates while allowing you to alter playback progress interactively.

Here is for example how you can create a `TimeSlider` view with a native slider updated every 1/10th of a second by a progress tracker. Note that the progress tracker must be explicitly bound to the player using the dedicated `bind(_:to:)` modifier:

```swift
private struct TimeSlider: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 10))

    var body: some View {
        Slider(progressTracker: progressTracker)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .bind(progressTracker, to: player)
    }
}
```

This `TimeSlider` can then be inserted into your player view hierarchy:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(items: [
        .simple(url: URL(string: "https://server.com/stream.m3u8")!),
        .urn("urn:rts:video:13444333")
    ])

    var body: some View {
        ZStack {
            VideoView(player: player)
            TimeSlider(player: player)
        }
        .onAppear(perform: player.play)
    }
}
```

By having the `ProgressTracker` stored in a nested view you ensure that only this part of the view hierarchy gets updated every 1/10th of a second. The main `PlayerView` itself is namely still only updated when the player state changes. This way you can avoid triggering frequent large view updates unnecessarily, which makes it possible to implement layouts in an energy-efficient way. Of course several progress trackers can be used should you want to have different parts of your user interface be updated at different rates.

To make it easier to spot where user interface updates can be optimized our `Core` package provides a `_debugBodyCounter(color:)` modifier which surrounds any view you want to observe with a counter, showing how many times its body has been evaluated. This way you can observe how your layout behaves and visually detects where parts of your user interface could benefit from local progress tracking.

## Maximized layout management (iOS)

Sometimes you want to enable behaviors only when a player view fills its parent context, for example zoom gestures which control the `VideoView` gravity.

Pillarbox does not implement such behaviors natively but instead provides a `LayoutReader` wrapper returning its layout information through a binding.

Here is for example how you could implement a pinch gesture only available when the player view is maximized in its parent context:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(items: [
        .simple(url: URL(string: "https://server.com/stream.m3u8")!),
        .urn("urn:rts:video:13444333")
    ])

    @State private var layoutInfo: LayoutInfo = .none
    @State private var gravity: AVLayerVideoGravity = .resizeAspect

    var body: some View {
        LayoutReader(layoutInfo: $layoutInfo) {
            VideoView(player: player, gravity: gravity)
                .gesture(magnificationGesture(), including: magnificationGestureMask)
                .ignoresSafeArea()
        }
        .onAppear(perform: player.play)
    }

    private var magnificationGestureMask: GestureMask {
        layoutInfo.isMaximized ? .all : .subviews
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                gravity = scale > 1.0 ? .resizeAspectFill : .resizeAspect
            }
    }
}
```

You can also use a layout reader to check whether the view covers the full screen.

## Playlists

A player can be loaded with several items to create a playlist. The playlist can be mutated at any time by inserting, deleting or moving items. Please refer to our extended playlist demo to discover what can be readily achieved with our current playlist API.

## AirPlay (iOS)

The player supports AirPlay. Please ensure that your application audio session and background modes are configured appropriately.

## Control center integration (iOS)

The player is automatically integrated with the control center. Currently only the most recent player instance is registered with the control center. This behavior will be further improved in the future, though.

## Custom player items

Pillarbox provides a way to retrieve a content URL and related metadata from any service:

1. Write a publisher which retrieves the URL to be played as well as any required metadata you might need.
2. Map the result of your publisher into an `Asset`. Three categories of assets are provided:
   - Simple assets which can be played directly.
   - Custom assets which require a custom resource loader delegate.
   - Encrypted assets which require a FairPlay content key session delegate.
3. If you want to provide asset metadata, most notably for tracker integration (see next section), just define a corresponding type and associate an instance with your asset.
4. Create a `PlayerItem` with the corresponding initializer taking a publisher as argument.

The resulting player item can then be played in a Pillarbox `Player` instance. It can also be shared so that other products can easily play content you provide.

## Custom item tracking

Pillarbox makes it possible to easily integrate any kind of tracker, mostly for analytics or QoS needs. Proceed as follows to implement your own tracker:

1. Create a new tracker class, say `CustomTracker`, and add conformance to the `PlayerItemTracker` protocol.
2. The `PlayerItemTracker` protocol declares `Configuration` and `Metadata` associated types. If your tracker requires a configuration or metadata related to the item being tracked just create dedicated types which contain all required parameters. Use `Void` for any type that is not required for your tracker.
3. Trackers are automatically instantiated by the item they are associated with. You therefore never instantiate a tracker directly but rather achieve the behavior you need by implementing `PlayerItemTracker` lifecycle methods instead:
  - When created `init(configuration:metadataPublisher:)` is called on your tracker with the configuration you provided as well as a publisher for the metadata type you chose. You can either use these values directly to setup your tracker or store them for later use.
  - Subscribe to player events which must be followed in `enable(for:)`. This method is called when the item to which the tracker is bound becomes the current one. Store the subscription tokens in your tracker and implement how the tracker should handle the events you subscribed to.
  - Metadata updates are automatically received from the `metadataPublisher`. You can combine this publisher with other publishers like `$playbackState` to achieve the behavior you need.
  - Cancel subscriptions in `disable()` by discarding the tokens you stored. This method is called when the item to which the tracker is bound stops being the current one.
  - You can perform any necessary final cleanup in `deinit` which is called when the player item and its trackers are discarded.

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

## Have fun

This is only a glimpse of what can be achieved with Pillarbox. Though the feature set is still limited you should already be able to implement pretty interesting playback experiences. Please have a look at the documentation (which can be built with Xcode _Product_ > _Build Documentation_) and check the demo and its various examples to better understand what is possible.
