# Selecting Subtitles and Alternative Audio Tracks

@Metadata {
    @PageColor(purple)
}

Manage subtitles and alternative audio tracks so that users can watch content in their preferred language.

## Overview

Media selection relates to the management of options sharing the same [AVMediaCharacteristic](https://developer.apple.com/documentation/avfoundation/avmediacharacteristic). To ensure the best possible user experience ``Player`` provides first-class built-in support for audible (audio tracks) and legible (subtitles) characteristics: 

- Automatic option selection based on preferred languages and characteristics.
- Current subtitle selection persistence between media playbacks apps via [Media Accessibility](https://developer.apple.com/documentation/mediaaccessibility/). 
- Audio Description (AD), Subtitles for the Deaf or Hard-of-Hearing (SDH) and Closed Captions (CC) support according to user accessibility preferences.
- Forced subtitles display.

### Manage media selection programmatically

Media selection belongs to essential properties automatically published by a ``Player`` instance, as explained in <doc:state-observation>. SwiftUI views observing a player instance will therefore be automatically redrawn when the list of available media selection options changes, but also when the option is updated.

You can list available options for a characteristic using ``Player/mediaSelectionOptions(for:)`` and retrieve or update the current selection with ``Player/selectedMediaOption(for:)`` and ``Player/select(mediaOption:for:)`` respectively. The list of available characteristics itself must be retrieved by calling ``Player/mediaSelectionCharacteristics`` first. 

> Tip: Custom user interfaces written in SwiftUI should directly use ``Player/mediaOption(for:)``, which returns a binding to the current media selection for some characteristic.

### Set preferred languages and characteristics

Depending on system language, accessibility settings and available renditions for a characteristics, the player always attempts to pick the best possible combination of audio track and subtitles when playing some content.

You can programmatically override the current preferred languages and characteristics for a player instance by calling ``Player/setMediaSelection(preferredLanguages:for:)``, though. Preferences can not only be updated during playback but also even before playback starts. This can be useful if your app manages its own language preference setting which should take precedence over system defaults.

> Note: Trust the system defaults in most case. They provide the best possible experience by taking into account user preferences and recent choices made in other media playback apps.

### Display media selection

Most of the time all that is required when implementing a playback user experience is a way for users to change the current subtitles or audio track selection.

If you need a menu matching the standard system player experience simply call ``Player/standardSettingMenu()`` and wrap its returned view into a [Menu](https://developer.apple.com/documentation/swiftui/menu). The obtained menu not only offers media selection for audible and legible characteristics, but also playback speed selection.

If you want to build your own menu you can retrieve the media selection submenu for some characteristic with ``Player/mediaSelectionMenu(characteristic:)``. 

You can also build an entirely custom media selection user interface with the help of the media selection APIs listed above.

## Stream packaging requirements 
