# Getting started

> 🚧 This documentation is a work-in-progress and focuses on basic Pillarbox integration only.

The following guide describes basic integration of the Pillarbox player into an application. This guide assumes SwiftUI usage, though Pillarbox can also be integrated into UIKit-based applications.

## Imports

To instantiate the player you must import the associated package package first:

```swift
import Player
```

This package also provides basic user components to build a player user interface. 

### Remark

If you need to access `AVFoundation` APIs please import the associated framework directly, as Pillarbox dependencies are not automatically pulled when importing one of its packages.

## Player instantiation

In your SwiftUI view simply instantiate and store a `Player` as `@StateObject`. You can provide one or several items to be played at construction time:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(
        item: PlayerItem(url: URL(string: "https://server.com/stream.m38u")!)
    )

    // ...
}
```

You can also create an empty `Player` and update its item list at a later time.

## Basic video view

Once you have a player you can display its contents in a `VideoView`, provided you are playing video content of course. Since the player is initialized in a paused state you probably want to call `play()` when the view appears:

```swift
struct PlayerView: View {
    @StateObject private var player = Player(
        item: PlayerItem(url: URL(string: "https://server.com/stream.m38u")!)
    )

    var body: some View {
        VideoView(player: player)
            .onAppear {
                player.play()
            }
    }
}
```

## Advanced view layouts

Pillarbox currently does not provide any standard playback view you can use but you can build one yourself. Since `Player` is an `ObservableObject`, though, implementation of a playback view can be achieved in the same was as for any usual SwiftUI view.

When significant changes occur within the player (e.g. state or buffering updates) the body of any SwiftUI view observing the player will namely be evaluated again. You can use states available from `Player` to display various UI elements in an appropriate state (e.g. displaying a playback button which can be used to pause or resume playback).

## Have fun

This is only a glimpse of what can be achieved with Pillarbox. Though the feature set is still limited you should already be able to implement pretty interesting playback experiences. Please have a look at the documentation (which can be built with Xcode _Product_ > _Build Documentation_) and check the demo and its various examples to better understand what is possible.

