# User Interface

@Metadata {
    @PageColor(purple)
}

Display a user interface for content being played.

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
