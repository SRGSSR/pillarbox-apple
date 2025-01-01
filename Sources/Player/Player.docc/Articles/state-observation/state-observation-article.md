# State Observation

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: state-observation-card, alt: "An eye image.")
}

Learn how to observe and respond to state changes in a player.

## Overview

The ``PillarboxPlayer`` framework leverages [Combine](https://developer.apple.com/documentation/combine), [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject), and published properties, allowing SwiftUI views to automatically react to changes in state.

However, indiscriminate property publishing can lead to excessive updates, causing unnecessary SwiftUI view refreshes, degraded layout performance, and higher energy consumption. To address this, ``Player`` only publishes essential states (e.g., playback status or media type), while other frequently updated states require explicit subscription.

### Observe essential player states

Essential states like ``Player/playbackState`` or ``Player/mediaType`` are automatically published, enabling simple implementation of playback-related UI components. Here’s an example:

```swift
struct PlaybackView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://www.server.com/master.m3u8")!)
    )

    var body: some View {
        VStack {
            VideoView(player: player)
            Button(action: player.togglePlayPause) {
                Text(player.shouldPlay ? "Pause" : "Play")
            }
        }
    }
}
```

### Observe time updates

Accurate time tracking is crucial for playback features like progress bars. However, to prevent excessive layout refreshes, a ``Player`` does not automatically publish time updates.

In SwiftUI, use a ``ProgressTracker`` to efficiently manage and observe progress changes. When bound to a player, a progress tracker not only provides automatic progress updates but also allows the user to interactively adjust the progress.

In other contexts, you can directly subscribe to time update publishers:

- Use ``Player/periodicTimePublisher(forInterval:queue:)`` for periodic updates.
- Use ``Player/boundaryTimePublisher(for:queue:)`` to detect specific time crossings.

### Explicitly subscribe to non-essential state updates

Non-essential states (e.g., buffer positions or derived properties like stream type) are not automatically published. Instead, you can:

- Subscribe to ``Player/propertiesPublisher`` for direct observation.
- Use the ``SwiftUICore/View/onReceive(player:assign:to:)`` modifier to observe specific property changes locally. For example, to display a loading indicator during buffering:

```swift
struct PlaybackView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://www.server.com/master.m3u8")!)
    )
    @State private var isBusy = false

    var body: some View {
        ZStack {
            VideoView(player: player)
            ProgressView()
                .opacity(isBusy ? 1 : 0)
        }
        .onAppear(perform: player.play)
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }
}
```

For a comprehensive list of observable properties, see ``PlayerProperties``.

### Respond to state changes

To react to specific state changes, use the ``SwiftUICore/View/onReceive(player:at:perform:)`` modifier. For instance, to perform an action when playback ends:

```swift
struct PlaybackView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://www.server.com/master.m3u8")!)
    )

    var body: some View {
        ZStack {
            VideoView(player: player)
        }
        .onReceive(player: player, at: \.playbackState) { playbackState in
            guard playbackState == .ended else { return }
            // Handle playback end
        }
    }
}
```

### Use SwiftUI property wrappers wisely

 [Proper use](https://developer.apple.com/documentation/swiftui/model-data) of SwiftUI property wrappers ensures efficient UI updates. Below are common patterns:

1. **Player Neither Owned nor Observed:** Pass the player as a constant:

    ```swift
    struct Widget: View {
        let player: Player

        var body: some View {
            // Not updated when the player publishes changes
        }
    }
    ```

2. **Player Owned but Not Observed:** Store the player in a `@State`:

    ```swift
    struct PlayerInterface: View {
        @State var player = Player(item: .urn("urn:rts:video:13444390"))

        var body: some View {
            // Not updated when the player publishes changes
        }
    }
    ```

3. **Player Not Owned but Observed:** Receive the player as an `@ObservedObject`:

    ```swift
    struct Widget: View {
        @ObservedObject var player: Player

        var body: some View {
            // Updated when the player publishes changes
        }
    }
    ```

4. **Player Owned and Observed:** Store the player in a `@StateObject`:

    ```swift
    struct PlayerInterface: View {
        @StateObject var player = Player(item: .urn("urn:rts:video:13444390"))

        var body: some View {
            // Updated when the player publishes changes
        }
    }
    ```

### Optimize state observations

To minimize unnecessary UI refreshes, keep subscriptions scoped to the smallest required view hierarchy:

- Use `View/_debugBodyCounter()` (from the PillarboxCore framework) to identify excessive view refreshes.
- Move high-frequency updates (e.g., progress tracking with small intervals or explicit ``SwiftUICore/View/onReceive(player:assign:to:)`` subscriptions) into smaller subviews.
- Recheck your layout with `View/_debugBodyCounter()` after implementing optimizations.

> Note:  Refer to the <doc:optimizing-custom-layouts> tutorial for detailed optimization techniques.
