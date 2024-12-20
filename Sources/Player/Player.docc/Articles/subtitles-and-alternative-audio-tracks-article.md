# Subtitles and Alternative Audio Tracks

@Metadata {
    @PageColor(purple)
}

Enable users to enjoy content in their preferred language by managing subtitles and alternative audio tracks.

## Overview

Media selection refers to managing options that share the same [AVMediaCharacteristic](https://developer.apple.com/documentation/avfoundation/avmediacharacteristic), such as legible (subtitles) or audible (audio tracks).

To deliver a seamless user experience, ``Player`` offers robust media selection support:

- **Automatic Selection:** Chooses options based on preferred languages and characteristics.
- **Selection Persistence:** Retains current subtitle choices across media playback apps using [Media Accessibility](https://developer.apple.com/documentation/mediaaccessibility/).
- **Accessibility Support:** Honors user preferences for Audio Description (AD), Subtitles for the Deaf or Hard-of-Hearing (SDH), and Closed Captions (CC).
- **Forced Subtitles:** Ensures display of forced subtitles when required.

### Manage media selection programmatically

Media selection is a core property of a ``Player`` instance and is automatically published, as detailed in <doc:state-observation-article>. SwiftUI views observing a Player instance will automatically update when media selection options or the current selection changes.

Use the following APIs to manage media selection programmatically:

- **List Options:** Retrieve available options for a characteristic using ``Player/mediaSelectionOptions(for:)``.
- **Get Current Selection:** Access the current selection with ``Player/selectedMediaOption(for:)``.
- **Update Selection:** Change the selection with ``Player/select(mediaOption:for:)``. To identify available characteristics, first call ``Player/mediaSelectionCharacteristics``.

> Tip: When using SwiftUI, leverage ``Player/mediaOption(for:)``, which provides a binding to the current selection for a characteristic.

### Set preferred languages and characteristics

``Player`` automatically selects the best combination of audio tracks and subtitles based on system language, accessibility settings, and available renditions.

To override default preferences, call ``Player/setMediaSelection(preferredLanguages:for:)``. Preferences can be updated during playback or configured beforehand, which is useful if your app includes a custom language preference setting that should take precedence over system defaults.

> Note: In most cases, rely on system defaults. They optimize user experience by incorporating accessibility preferences and recent user selections from other media apps.

### Display media selection

For most playback user interfaces, all you need is a way to let users switch subtitles or audio tracks:

- To replicate the standard system player experience, use ``Player/standardSettingMenu()`` and embed its result in a [Menu](https://developer.apple.com/documentation/swiftui/menu). This menu includes options for media selection and playback speed.
- To customize menus further, use ``Player/mediaSelectionMenu(characteristic:)`` to retrieve a submenu for a specific characteristic.
- For complete control, use the media selection APIs to build a fully custom interface.

### Stream packaging requirements

Automatic media selection depends on properly packaged content, as outlined in <doc:stream-encoding-and-packaging-advice-article>. If automatic selection does not behave as expected, consult the included troubleshooting guide.
