# Playback Speed

@Metadata {
    @PageColor(purple)
}

Control the pace at which content is played.

## Overview

Some users prefer playing content at faster or slower speeds. You can adjust the playback speed of a ``Player`` programmatically at any time. Controls can also be provided to let users change the playback speed.

### Adjust the playback speed programmatically

Playback speed information belongs to essential properties automatically published by a ``Player`` instance, as explained in <doc:state-observation-article>. SwiftUI views observing a player instance will therefore be automatically redrawn when playback speed changes.

You can adjust the speed at which content is played using the ``Player/setDesiredPlaybackSpeed(_:)`` method. As its name suggests this method only sets a desired speed. The actual speed might be limited by the content being played. The current effective playback speed can be queried with ``Player/effectivePlaybackSpeed``, while the available speed range can be retrieved from ``Player/playbackSpeedRange``.

> Tip: Custom user interfaces written in SwiftUI should directly use ``Player/playbackSpeed``, which returns a binding to the current playback speed.

### Provide speed controls

Most of the time all that is required when implementing a playback user interface is a way for users to change the current playback speed.

If you need a menu matching the standard system player experience simply call ``Player/standardSettingMenu()`` and wrap its returned view into a [Menu](https://developer.apple.com/documentation/swiftui/menu). The obtained menu not only offers media selection for audible and legible characteristics but also playback speed selection.

If you want to build your own menu you can retrieve the playback speed submenu with ``Player/playbackSpeedMenu(speeds:)``.  This lets you build a menu with entries tailored to your app needs, including the list of speeds you want to support.

You can also build an entirely custom media selection user interface with the help of the playback speed APIs listed above.
