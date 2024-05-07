# Stream packaging advice

@Metadata {
    @PageColor(purple)
}

Package streams for optimal compatibility with the PillarboxPlayer framework.

## Overview

The optimal playback experience which can be obtained with the PillarboxPlayer framework requires streams to be packaged accordingly. This most notably affects the ability of the player to automatically apply default media selections as well as the quality of its scrubbing user experience.

More information about automatic selection is available from <doc:subtitles-and-alternative-audio-tracks>.

### Automatic media option selection

``Player`` supports automatic media option selection based on language and accessibility settings (e.g. unforced subtitles, CC, SDH and audio description), both for audible and legible renditions. This requires streams to satisfy common requirements which are listed below.

#### Audio renditions

For automatic selection to work with audio description be sure that the corresponding [renditions](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.1) have the `public.accessibility.describes-video` characteristic.

All renditions should also have their `AUTOSELECT` attribute set to `YES` so that the player can consider them for automatic selection.

#### Legible renditions

For automatic selection to work with legible renditions:

- Unforced `SUBTITLES` and `CLOSED-CAPTIONS` renditions must have their `AUTOSELECT` attribute set to `YES` so that the player can choose among them in _Automatic_ mode.
- Forced `SUBTITLES` renditions [must](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Subtitles) have their `AUTOSELECT` attribute set to `YES`. Note that ``Player`` follows [Apple recommendations](https://developer.apple.com/library/archive/releasenotes/AudioVideo/RN-AVFoundation/index.html#//apple_ref/doc/uid/TP40010717-CH1-DontLinkElementID_3) and never returns forced subtitles for selection.

#### CC and SDH

``Player`` supports closed captions (CC) and Subtitles for the Deaf or Hard-of-Hearing (SDH):

- CC renditions are identified by the `CLOSED-CAPTIONS` type. They must also have their `AUTOSELECT` attribute set to `YES`.
- SDH renditions [must](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Accessibility) have the `SUBTITLES` type and the `public.accessibility.transcribes-spoken-dialog` and `public.accessibility.describes-music-and-sound` characteristics. They must also have their `AUTOSELECT` attribute set to `YES`.

#### Troubleshooting

If you think audible or legible renditions are incorrectly handled for some content you play with a ``Player`` instance, please check the following in order:

1. Check that your master playlist adopts the standards listed in this document. You should in particular ensure that `AUTOSELECT`, `FORCED` and accessibility characteristics are properly set.
2. If your master playlist is correct then check system settings on your device. Automatic audible and legible rendition selection namely strongly depends on:
    - The list of preferred languages defined in the system settings (all languages are considered as potentially understood by the user) and their relative order. Remove languages that you do not expect and reorder the list as appropriate.
    - The user accessibility settings (AD and SDH / CC preferences). Enable or disable these settings according to your needs.
3. Whether your code overrides rendition selection with ``Player/setMediaSelection(preferredLanguages:for:)``.

### Trick mode / Trick play

``Player`` supports [trick mode](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play) (aka trick play) which requires dedicated I-frame playlists to be delivered in video master playlists to provide for a [faster scrubbing experience](https://en.wikipedia.org/wiki/Trick_mode).

The player still attempts to offer a good scrubbing experience when I-frame playlists are not available. In this case seek requests are performed in sequence, avoiding pending request interruption and eliminating superfluous seeks (an approach called _smooth seeking_). Note that this experience is an order of magnitude slower than the one obtained with trick mode, though.

Note that I-frame playlists are a [must-have](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play) for tvOS since they are the only way to provide previews during scrubbing.

### Links

Please refer to the official documentation for more information:

- [HTTP Live Streaming](https://developer.apple.com/streaming/)
- [HLS Authoring Specification for Apple Devices](https://developer.apple.com/documentation/http_live_streaming/hls_authoring_specification_for_apple_devices/)
- [RFC 8216](https://tools.ietf.org/html/rfc8216/)
- [Playlist examples](https://developer.apple.com/documentation/http-live-streaming/example-playlists-for-http-live-streaming)
