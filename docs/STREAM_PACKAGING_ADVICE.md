# Stream packaging advice

This article discusses how streams should be packaged for optimal compatibility with Pillarbox player.

## Automatic media option selection

Pillarbox player supports automatic media option selection based on:

- System language and accessibility settings (e.g. unforced subtitles and audio description).
- Content language (e.g. forced subtitles).

For automatic selection to work with legible [renditions](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.1):

- Unforced `SUBTITLES` and `CLOSED-CAPTIONS` renditions must have their `AUTOSELECT` attribute set to `YES` so that the player can choose among them in _Automatic_ mode.
- Forced `SUBTITLES` renditions must have their `AUTOSELECT` attribute set to `YES`. Note that Pillarbox player follows [Apple recommendations](https://developer.apple.com/library/archive/releasenotes/AudioVideo/RN-AVFoundation/index.html#//apple_ref/doc/uid/TP40010717-CH1-DontLinkElementID_3) and never returns forced subtitles for selection.

## Trick mode / Trick play

Pillarbox player supports [trick mode](https://en.wikipedia.org/wiki/Trick_mode) (aka trick play) which requires dedicated I-frame playlists to be delivered in video master playlists. Please refer to the [HTTP Live Streaming (HLS) authoring specification for Apple devices](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices?language=objc) for more information.

The player still attempts to provide the best possible seek experience when I-frame playlists are not available. In this case the player performs seek requests in sequence, avoiding pending request interruption and unnecessary seeks (an approach called _smooth seeking_). Note that this experience is an order of magnitude slower than the one obtained with trick mode, though.
