# User Interface

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: user-interface-card, alt: "An image depicting a user interface.")
}

Deliver intuitive playback experiences.

## Overview

``PillarboxPlayer`` provides SwiftUI views that are easy to integrate, as well as APIs that let you build fully customized player interfaces.

## System video view

``SystemVideoView`` is a SwiftUI view that delivers Apple's built-in playback experience, powered by ``Player``. If your app does not require a custom playback interface—or if you want to stay as close as possible to the native experience—integrating this view is straightforward:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(
        item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    )

    var body: some View {
        SystemVideoView(player: player)
            .onAppear(perform: player.play)
    }
}
```

> Note: On Apple TV, always use ``SystemVideoView`` to deliver the optimal platform-wide playback experience. The tvOS playback interface is regularly updated to match new platform standards, while remaining accessible and controllable with a TV remote. Some essential components, such as sliders, are not provided on tvOS. Unless your app has very specific needs and significant resources, avoid building a custom playback interface on tvOS.

## Custom playback views

If the built-in playback experience does not fit your needs, you can create your own interface from scratch, starting with a ``VideoView`` and composing your layout in SwiftUI, based on automatic ``Player`` state observation. ``PillarboxPlayer`` provides several utilities for common playback UI requirements, including:

- ``ProgressTracker`` to handle playback position, for example in combination with ``SwiftUI/Slider``.
- ``VisibilityTracker`` to manage control visibility.
- ``LazyImage`` to display artwork associated with ``PlayerItem``s.
- ``SkipTracker`` to implement multi-tap gestures for fast skipping.

For a step-by-step introduction to building custom playback interfaces, see the <doc:building-custom-user-interfaces> tutorial.
