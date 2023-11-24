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
- Controls are shown when playback is paused externally (e.g. by another app or through the control center), inviting the user to resume playback.

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
        .animation(.linear(duration: 0.2), value: visibilityTracker.isUserInterfaceHidden)
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

To ensure that controls stay visible when the user is somehow interacting with them we can call `visibilityTracker.reset()` to reset the automatic hiding mechanism. For example we can use a simultaneous drag gesture to recognize when the user interacts with their screen:

```swift
struct PlayerView: View {
    // ...

    var body: some View {
        ZStack {
            VideoView(player: player)
            controls()
        }
        .animation(.linear(duration: 0.2), value: visibilityTracker.isUserInterfaceHidden)
        .onTapGesture(perform: visibilityTracker.toggle)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in visibilityTracker.reset() }
        )
        .onAppear(perform: player.play)
        .bind(visibilityTracker, to: player)
    }
}
```

## Custom view layouts

Pillarbox currently does not provide any standard playback view you can use but you can build one yourself. Since `Player` is an `ObservableObject`, though, implementation of a playback view can be easily achieved in the same way as for any usual SwiftUI layout.

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

To make it easier to spot where user interface updates can be optimized our `Core` package provides a `_debugBodyCounter(color:)` modifier which surrounds any view you want to observe with a counter, showing how many times its body has been evaluated. This way you can observe how your layout behaves and visually detects where parts of your user interface could benefit from local progress tracking. This feature is only available in debug builds and requires the application to be run with the `PILLARBOX_DEBUG_BODY_COUNTER` environment variable set. It is also automatically enabled in Xcode previews.

## Contextual layout management (iOS)

Sometimes you want to enable behaviors only when a player view fills its parent context, for example zoom gestures which control the `VideoView` gravity.

Pillarbox does not implement such behaviors natively but instead provides a `readLayout(into:)` modifier returning its layout information through a binding.

Here is for example how you could implement a pinch gesture only available when the player view covers its current context:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(items: [
        .simple(url: URL(string: "https://server.com/stream.m3u8")!),
        .urn("urn:rts:video:13444333")
    ])

    @State private var layoutInfo: LayoutInfo = .none
    @State private var gravity: AVLayerVideoGravity = .resizeAspect

    var body: some View {
        VideoView(player: player, gravity: gravity)
            .readLayout(into: $layoutInfo)
            .gesture(magnificationGesture(), including: magnificationGestureMask)
            .ignoresSafeArea()
            .onAppear(perform: player.play)
    }

    private var magnificationGestureMask: GestureMask {
        layoutInfo.isOverCurrentContext ? .all : .subviews
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                gravity = scale > 1.0 ? .resizeAspectFill : .resizeAspect
            }
    }
}
```

You can also read the layout to check whether the view covers the full screen or not.

## Playlists

A player can be loaded with several items to create a playlist. The playlist can be mutated at any time by inserting, deleting or moving items. Please refer to our extended playlist demo to discover what can be readily achieved with our current playlist API.

## AirPlay and Control Center integration (iOS)

The player supports AirPlay and can be integrated with the Control Center:

- For AirPlay support please ensure that your application audio session and background capabilities are configured appropriately.
- Call `becomeActive()` on a player instance to enable AirPlay and Control Center support for it.
- Call `resignActive()` on a player to disable AirPlay and Control Center support for it (if currently active).

You need to call `becomeActive()` when transitioning to an immersive player experience for which these integrations make sense. Calling `resignActive()` is most of the time superfluous, except when the same player instance is reused between an immersive playback user interface and a limited playback experience.

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

Pillarbox makes it possible to easily integrate any kind of tracker, for example to gather analytics, QoS data or to save the current playback position into a history. Proceed as follows to implement your own tracker:

1. Create a new tracker class, say `CustomTracker`, and add conformance to the `PlayerItemTracker` protocol.
2. The `PlayerItemTracker` protocol declares `Configuration` and `Metadata` associated types. If your tracker requires a configuration or metadata related to the item being tracked just create dedicated types which contain all required parameters. Use `Void` for any type that is not required for your tracker.
3. Trackers are automatically instantiated by the item they are associated with. You therefore never instantiate a tracker directly but rather achieve the behavior you need by implementing `PlayerItemTracker` life cycle methods instead:
  - The `init(configuration:)` initializer is called on your tracker at creation time with the configuration you provided. You can either use this configuration directly to setup your tracker or store it for later use.
  - The `enable(for:)` method is called when the item to which the tracker is bound becomes the current one.
  - Metadata updates are automatically reported by the `updateMetadata(with:)` method.
  - Player property updates are automatically reported by the `updateProperties(with:)` method. Even if your tracker stores the player somehow you should rather use this method as the properties it publishes are guaranteed to be up-to-date. Be careful that properties can change often and that your implementation should be as efficient as possible.
  - Perform any required cleanup in `disable()`, which is called when the item to which the tracker is bound stops being the current one.
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

## Picture in Picture integration

Pillarbox provides two modes of integration for Picture in Picture:

- Basic integration, which enables Picture in Picture automatically when the application is sent to the background.
- Advanced integration, which in addition allows the user to navigate your application while playing content with Picture in Picture. This requires the addition of a dedicated button with which Picture in Picture can be started interactively.

No matter the integration mode you choose you must setup your application first so that it can support Picture in Picture.

### Application setup

For your application to be able to support Picture in Picture you must:

- Add _Audio, AirPlay, and Picture in Picture_ to your target _Background Modes_ capabilities.
- [Configure your audio session](https://developer.apple.com/documentation/avfaudio/avaudiosession) so that it uses the `.playback` category.

### Basic integration

Basic integration is as simple as enabling `isPictureInPictureSupported` for a `VideoView`.

`SystemVideoView` does not support basic integration.

#### Testing your integration

To test your integration:

1. Start playing a video in your player.
2. Send your application to the background. Playback should continue in Picture in Picture.
3. Return to your application. Playback should automatically continue in the application.

### Advanced integration

Advanced integration is more involved and requires additional integration steps so that Picture in Picture can:

- Dismiss and restore your player user interface when appropriate.
- Continue playing even when the player user interface has been dismissed.

Advanced integration is available both for `VideoView` as well as `SystemVideoView` and is usually achieved as follows:

1. Enable `isPictureInPictureSupported` for a `VideoView` or `SystemVideoView`.
2. Ensure your player view state can exist outside the view existence. One possible approach is to have a player view model which outlives its view, e.g. by storing it in a shared global state (e.g. a `static` property). The player view state should itself contain the `Player` instance used for playback.
3. Properly handle content updates in your shared player view state. Usually:
  - When opening a content not being played: Update your player with the new item.
  - When opening the same content already being played: Avoid updating your player so that playback can continue uninterrupted.
  - When clearing the content: Remove all items currently in the player queue.
4. To release resources when the player view is not needed anymore (i.e. when the player view is closed without activating Picture in Picture, or when Picture in Picture ends), apply the `enabledForInAppPictureInPictureWithCleanup(perform:)` modifier to the video view parent hierarchy, clearing your player view model state in its closure.
5. `SystemVideoView` provides a Picture in Picture button automatically. For `VideoView`-based custom layouts you must add a `PictureInPictureButton` directly to your player interface.
6. To dismiss / restore the player user interface when entering / exiting Picture in Picture, set a Picture in Picture life cycle delegate with the `PictureInPicture.setDelegate(_:)` method. A  generally good candidate is any routing-aware class of your application. Dismiss the player view when Picture in Picture is about to start, and restore it when it ends, calling the required completion handler at the end of your restoration animation.

#### Testing your integration

To test your integration:

1. Start playing a video in your player.
2. Send your application to the background. Playback should continue in Picture in Picture.
3. Return to your application. The player view should be dismissed and playback should continue in the Picture in Picture overlay.
4. Tap on the Picture in Picture restoration button. Your player user interface should be restored without playback interruption.
5. Tap on the Picture in Picture button. Playback should continue in Picture in Picture, within your application.
6. Play the same content already being played. The player user interface should be restored without playback interruption.
7. Tap on the Picture in Picture button. Playback should continue in Picture in Picture, within your application.
8. Play another video. The player user interface should be restored with playback transitioning to the new content.

#### `SystemVideoView` inline display

The above instructions assume you are using either `VideoView` in a custom layout, or `SystemVideoView` presented full screen.

When `SystemVideoView` is presented inline, though, its close button is replaced with a maximization button to switch to full screen display. Picture in Picture can be enabled whether the inline player has been maximized or not, and for this reason any life cycle implementation for the inline system player should not dismiss the player view when Picture in Picture is about to start. Implementing view restoration is still required, though.

#### Limitations

Switching between a `VideoView` and a `SystemVideoView` for the content currently being played in Picture in Picture is not supported and leads to undefined behavior.

## Background video playback

`Player` can be enabled for background video playback using `audiovisualBackgroundPlaybackPolicy`. For SRG SSR content, though, your application must not implement background video playback to avoid issues with comScore measurements. Please implement proper Picture in Picture support instead.

## Have fun

This is only a glimpse of what can be achieved with Pillarbox. Though the feature set is still limited you should already be able to implement pretty interesting playback experiences. Please have a look at the documentation (which can be built with Xcode _Product_ > _Build Documentation_) and check the demo and its various examples to better understand what is possible.
