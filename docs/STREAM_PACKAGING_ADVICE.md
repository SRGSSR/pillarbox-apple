# Stream packaging advice

This article discusses how streams should be packaged to benefit from Pillarbox support in the best possible way.

## Subtitles

Pillarbox supports automatic legible option selection based on:

- System language and accessibility settings (e.g. unforced subtitles and audio description).
- Content language (e.g. forced subtitles).

For automatic selection to work with legible [renditions](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.1):

- Unforced `SUBTITLES` and `CLOSED-CAPTIONS` renditions must have their `AUTOSELECT` attribute set to `YES` so that the player can choose among them in _Automatic_ mode.
- Forced `SUBTITLES` renditions must have their `AUTOSELECT` attribute set to `YES`. Note that Pillarbox follows [Apple recommendations](https://developer.apple.com/library/archive/releasenotes/AudioVideo/RN-AVFoundation/index.html#//apple_ref/doc/uid/TP40010717-CH1-DontLinkElementID_3) and never returns forced subtitles for selection.

## Trick mode / Trick play

Pillarbox supports [trick mode](https://en.wikipedia.org/wiki/Trick_mode) (aka trick play) which requires dedicated I-frame playlists to be delivered in video streams. Please refer to the [HTTP Live Streaming (HLS) authoring specification for Apple devices](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices?language=objc) for more information.

Pillarbox still attempts tp provide the best possible seek experience when these playlists are not present. This experience, described as _smooth seeking_, is an order of magnitude slower than the one obtained with trick mode, though.
