# Playback Speed

@Metadata {
    @PageColor(purple)
}

Control the pace at which content is played.

## Overview

Many users prefer playing content at customized speeds, whether faster or slower. You can adjust the playback speed of a ``Player`` programmatically at any time and optionally provide controls to allow users to modify the playback speed themselves.

### Adjust the playback speed programmatically

Playback speed is part of the essential properties automatically published by a ``Player`` instance, as detailed in the <doc:state-observation-article> article. SwiftUI views observing a player instance will automatically update when the playback speed changes.

To adjust the playback speed programmatically, use the ``Player/setDesiredPlaybackSpeed(_:)`` method. As the name implies, this method sets the desired speed. However, the actual speed may vary depending on the content’s limitations. You can query the current effective playback speed using ``Player/effectivePlaybackSpeed`` and retrieve the available speed range with ``Player/playbackSpeedRange``.

> Tip: For custom user interfaces built in SwiftUI, use ``Player/playbackSpeed``. This provides a binding to the current playback speed, ensuring seamless integration with SwiftUI views.

### Provide speed controls

When building a playback user interface, one of the most common requirements is to provide users with the ability to change the playback speed.

For a quick implementation, you can use the standard system player experience by calling ``Player/standardSettingsMenu(speeds:action:)``. Wrap the returned view in a [Menu](https://developer.apple.com/documentation/swiftui/menu) that offers not only playback speed selection but also media options for audible and legible characteristics.

If you want more customization, you can create your own menu using ``Player/playbackSpeedMenu(speeds:action:)``. This allows you to tailor the list of speed options to your app’s needs.

For a fully custom solution, you can design a bespoke media selection interface using the playback speed APIs described above.
