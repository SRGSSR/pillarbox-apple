# Stream Encoding and Packaging Advice

@Metadata {
    @PageColor(purple)
}

Encode and package streams for optimal compatibility with the PillarboxPlayer framework.

## Overview

Apple provides HLS [authoring specifications](https://developer.apple.com/documentation/http_live_streaming/hls_authoring_specification_for_apple_devices/) regarding encoding and packaging best practices for compatibility with Apple devices. These  specifications cover compatible codecs, encoding profiles or recommended encoding ladders, among many other topics.

For optimal playback experience with the PillarboxPlayer framework some of these specifications need to be followed rigorously. This article covers these specific requirements in more detail and provides more information about how streams can be tested for compatibility with PillarboxPlayer.

> Note: More information about automatic media selection is available from <doc:subtitles-and-alternative-audio-tracks>.

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

> Tip: Check the _Inspecting and testing streams_ section below for tools that can make troubleshooting easier.

### Trick mode / Trick play

``Player`` supports [trick mode](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play) (aka trick play) which requires dedicated I-frame playlists to be delivered in video master playlists to provide for a [faster scrubbing experience](https://en.wikipedia.org/wiki/Trick_mode).

The player still attempts to offer a good scrubbing experience when I-frame playlists are not available. In this case seek requests are performed in sequence, avoiding pending request interruption and eliminating superfluous seeks (an approach called _smooth seeking_). Note that this experience is an order of magnitude slower than the one obtained with trick mode, though.

Note that I-frame playlists are a [must-have](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play) for tvOS since they are the only way to provide previews during scrubbing.

### Inspecting and testing streams

Several tools are available for stream encoding and packaging teams to check that the streams they deliver work well with PillarboxPlayer.

#### HTTP Live Streaming Tools

Apple provides a series of command-line tools, available for macOS and CentOS Linux, on its [developer portal](https://developer.apple.com/download/all/) (a developer account is required).

These most notably contain the `mediastreamvalidator` command which which HLS streams can be validated. Please refer to the associated documentation for more information.

#### Inspection tools

The following commands can be useful to inspect streams:

- ffprobe, which is part of [ffmpeg](https://ffmpeg.org/ffprobe.html).
- [MediaInfo](https://mediaarea.net/en/MediaInfo), which provides a GUI as well as a command-line tool.

#### Proxy applications

Network activity associated with HLS streaming can be inspected with proxy tools like [Charles](https://www.charlesproxy.com) or [Proxyman](https://proxyman.io). Please refer to their respective documentation for more information.

#### Official Apple players

HLS streams can always be tested with a variety of native players, most notably:

- Safari on macOS.
- Safari on iOS / iPadOS.
- QuickTime Player on macOS.

> Important: Streams that cannot be correctly played with Apple official players will almost certainly fail to play correctly with PillarboxPlayer.

#### 3rd party players

HLS streams can be tested with 3rd party players, mostly on the web. These include:

- hls.js, which provides an [official online playground](https://hlsjs.video-dev.org/demo).
- [Video.js](https://videojs.com/), for which [official](https://videojs-http-streaming.netlify.app) and [non-official](https://amtins.github.io/cassettator-forbidden-adventures/) online playgrounds are available.

#### Pillarbox demo

Any URL, including SRG SSR URLs protected with DRM or a token, can be played directly with Pillarbox demo. You can install the iOS and tvOS demo applications by registering [with TestFlight](https://testflight.apple.com/join/TS6ngLqf) (an Apple ID is required).

### Technical documentation

Please refer to the official documentation for more information:

- [HTTP Live Streaming](https://developer.apple.com/streaming/)
- [HLS Authoring Specification for Apple Devices](https://developer.apple.com/documentation/http_live_streaming/hls_authoring_specification_for_apple_devices/)
- [RFC 8216](https://tools.ietf.org/html/rfc8216/)
- [Playlist examples](https://developer.apple.com/documentation/http-live-streaming/example-playlists-for-http-live-streaming)
