# Stream packaging advice

This article discusses how streams should be packaged for optimal compatibility with Pillarbox player.

## Automatic media option selection

Pillarbox player supports automatic media option selection based on:

- System language and accessibility settings (e.g. unforced subtitles, CC, SDH and audio description).
- Content language (e.g. forced subtitles).

### Audio renditions

For automatic selection to work with audio description be sure that the corresponding [renditions](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.1) have the `public.accessibility.describes-video` characteristic.

### Legible renditions

For automatic selection to work with legible renditions:

- Unforced `SUBTITLES` and `CLOSED-CAPTIONS` renditions must have their `AUTOSELECT` attribute set to `YES` so that the player can choose among them in _Automatic_ mode.
- Forced `SUBTITLES` renditions must have their `AUTOSELECT` attribute set to `YES`. Note that Pillarbox player follows [Apple recommendations](https://developer.apple.com/library/archive/releasenotes/AudioVideo/RN-AVFoundation/index.html#//apple_ref/doc/uid/TP40010717-CH1-DontLinkElementID_3) and never returns forced subtitles for selection.

### CC and SDH

Pillarbox player supports closed captions (CC) and Subtitles for the Deaf or Hard-of-Hearing (SDH):

- CC renditions are identified by the `CLOSED-CAPTIONS` type. They must also have their `AUTOSELECT` attribute set to `YES`.
- SDH [must](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Accessibility) renditions must have the `SUBTITLES` type and the `public.accessibility.transcribes-spoken-dialog` and `public.accessibility.describes-music-and-sound` characteristics. They must also have their `AUTOSELECT` attribute set to `YES`.

## Trick mode / Trick play

Pillarbox player supports [trick mode](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play) (aka trick play) which requires dedicated I-frame playlists to be delivered in video master playlists to provide for a [faster seeking experience](https://en.wikipedia.org/wiki/Trick_mode).

The player still attempts to provide a good seek experience when I-frame playlists are not available. In this case seek requests are performed in sequence, avoiding pending request interruption and eliminating superfluous seeks (an approach called _smooth seeking_). Note that this experience is an order of magnitude slower than the one obtained with trick mode, though.
