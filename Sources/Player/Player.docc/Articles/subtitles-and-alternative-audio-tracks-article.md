# Subtitles and Alternative Audio Tracks

@Metadata {
    @PageColor(purple)
}

Manage subtitles and alternative audio tracks to let users watch content in their preferred language.

## Overview

Media selection designates the management of options sharing the same [AVMediaCharacteristic](https://developer.apple.com/documentation/avfoundation/avmediacharacteristic), most notably legible (subtitles) or audible (audio tracks).

To ensure the best possible user experience ``Player`` provides first-class media selection support:

- Automatic option selection based on preferred languages and characteristics.
- Current subtitle selection persistence between media playbacks apps via [Media Accessibility](https://developer.apple.com/documentation/mediaaccessibility/).
- Audio Description (AD), Subtitles for the Deaf or Hard-of-Hearing (SDH) and Closed Captions (CC) support according to user accessibility preferences.
- Forced subtitles display.

### Manage media selection programmatically

Media selection belongs to essential properties automatically published by a ``Player`` instance, as explained in <doc:state-observation-article>. SwiftUI views observing a player instance will therefore be automatically redrawn when the list of available media selection options is updated, but also when selection itself changes.

You can list available options for a characteristic using ``Player/mediaSelectionOptions(for:)``, retrieve the current selection with ``Player/selectedMediaOption(for:)`` or update it with ``Player/select(mediaOption:for:)``. The list of available characteristics itself must be retrieved by calling ``Player/mediaSelectionCharacteristics`` first.

> Tip: Custom user interfaces written in SwiftUI should directly use ``Player/mediaOption(for:)``, which returns a binding to the current media selection for some characteristic.

### Set preferred languages and characteristics

Depending on system language, accessibility settings and available renditions for a characteristic, a ``Player`` instance always attempts to pick the best possible combination of audio track and subtitles when playing some content.

You can programmatically override the current preferred languages and characteristics for a player instance by calling ``Player/setMediaSelection(preferredLanguages:for:)``. Preferences can not only be updated during playback but also even before playback starts. This can be useful if your app manages its own language preference setting which should take precedence over system defaults.

> Note: You should trust the system defaults in most case. They provide the best possible user experience by taking into accessibility preferences and recent choices made in other media playback apps.

### Display media selection

Most of the time all that is required when implementing a playback user interface is a way for users to change the current subtitles or audio track.

If you need a menu matching the standard system player experience simply call ``Player/standardSettingMenu()`` and wrap its returned view into a [Menu](https://developer.apple.com/documentation/swiftui/menu). The obtained menu not only offers media selection for audible and legible characteristics but also playback speed selection.

If you want to build your own menu you can retrieve the media selection submenu for some characteristic with ``Player/mediaSelectionMenu(characteristic:)``.  This lets you build a menu with entries tailored to your app needs.

You can also build an entirely custom media selection user interface with the help of the media selection APIs listed above.

### Stream packaging requirements

Automatic media selection requires content to be packaged according to standards discussed in <doc:stream-encoding-and-packaging-advice-article>. Please check the associated troubleshooting guide should automatic selection not work according to your expectations.
