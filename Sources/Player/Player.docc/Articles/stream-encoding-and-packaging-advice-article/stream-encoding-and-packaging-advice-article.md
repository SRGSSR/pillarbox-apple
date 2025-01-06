# Stream Encoding and Packaging Advice

@Metadata {
    @PageColor(purple)
}

Optimize your streams for seamless playback with Pillarbox.

## Overview

Apple’s [HLS authoring specifications](https://developer.apple.com/documentation/http_live_streaming/hls_authoring_specification_for_apple_devices/) provide guidance on encoding and packaging for Apple device compatibility, covering codecs, encoding profiles, and recommended encoding ladders.

For optimal compatibility with the ``PillarboxPlayer`` framework, certain specifications must be followed closely. This guide outlines these key requirements and provides tools for testing stream compatibility with ``PillarboxPlayer``.

> Note: For more on automatic media selection, refer to <doc:subtitles-and-alternative-audio-tracks-article>.

### Automatic media option selection

``Player`` supports automatic selection of audio and subtitle tracks based on language preferences and accessibility settings (e.g., unforced subtitles, CC, SDH, and audio descriptions). This feature requires streams to meet specific criteria:

#### Audio renditions

- Include the `public.accessibility.describes-video` characteristic for audio description [renditions](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.1).
- Set the `AUTOSELECT` attribute to `YES` for all renditions to enable automatic selection.

#### Subtitle renditions

- **Unforced Subtitles:** Set `AUTOSELECT` to `YES` for `SUBTITLES` and `CLOSED-CAPTIONS` renditions to allow selection in _Automatic_ mode.
- **Forced Subtitles:** [Ensure](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Subtitles) `FORCED` and `AUTOSELECT` are set to `YES`. ``Player`` adheres to [Apple's' recommendations](https://developer.apple.com/library/archive/releasenotes/AudioVideo/RN-AVFoundation/index.html#//apple_ref/doc/uid/TP40010717-CH1-DontLinkElementID_3) and never returns forced subtitles for explicit user selection.

#### Closed Captions (CC) and Subtitles for the Deaf or Hard-of-Hearing (SDH)

- **CC:** Use the `CLOSED-CAPTIONS` type and set `AUTOSELECT` to `YES`.
- **SDH:** Use the `SUBTITLES` type with the `public.accessibility.transcribes-spoken-dialog` and `public.accessibility.describes-music-and-sound` characteristics, and set `AUTOSELECT` to `YES`.

#### Troubleshooting rendition selection

If renditions are not handled as expected:

1. **Validate the Master Playlist:** Confirm attributes like `AUTOSELECT`, `FORCED`, and accessibility characteristics are correctly set.
2. **Check System Settings**: Ensure the device’s system settings are configured with appropriate:
    - **Languages:** List and order preferred languages correctly.
    - **Accessibility Settings:** Enable or disable AD and SDH/CC preferences as needed.
3. **Inspect your Code:** Verify that ``Player/setMediaSelection(preferredLanguages:for:)`` is not overriding automatic selection.

> Tip: Refer to the _Inspecting and testing streams_ section for useful troubleshooting tools.

### Trick mode (Trick play)

``Player`` supports [trick mode](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play), which uses I-frame playlists for [fast scrubbing](https://en.wikipedia.org/wiki/Trick_mode). If I-frame playlists are unavailable, ``Player`` implements _smooth seeking_, optimizing scrubbing by avoiding redundant seeks. However, this fallback is significantly slower.

> Note: I-frame playlists are [mandatory](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices#Trick-Play) for tvOS ``SystemVideoView`` to provide preview functionality during scrubbing.

### Inspecting and testing streams

Use the following tools to ensure streams meet ``PillarboxPlayer`` compatibility requirements:

#### HTTP Live Streaming Tools

Apple provides HLS validation tools for macOS, accessible through the [developer portal](https://developer.apple.com/download/all/). Notable tools include:

- `mediastreamvalidator`: Validates HLS streams and generates reports.
- `hlsreport`: Creates HTML summaries from `mediastreamvalidator` JSON reports, highlighting violations and discontinuities (use the `--disc` parameter).

> Note: Consult the tool’s man pages for detailed usage instructions.

#### Inspection tools

These tools help analyze stream properties and compliance:

- `ffprobe`, which is part of [ffmpeg](https://ffmpeg.org/ffprobe.html).
- [TSDuck](https://tsduck.io/).
- [MediaInfo](https://mediaarea.net/en/MediaInfo), which offers GUI and command-line utilities.

#### Proxy applications

Inspect HLS network activity using tools like:

- [Charles](https://www.charlesproxy.com).
- [Proxyman](https://proxyman.io).

> Note: Consult the tool’s documentations for detailed usage instructions.

#### Official Apple players

Test streams with native Apple players to ensure compatibility:

- Safari on macOS.
- Safari on iOS/iPadOS.
- QuickTime Player on macOS.

> Important: Streams that fail in these players are likely to fail with ``PillarboxPlayer``.

#### Third-party players

Test streams on third-party platforms, such as:

- hls.js, which provides an [official online playground](https://hlsjs.video-dev.org/demo).
- [Video.js](https://videojs.com/), for which [official](https://videojs-http-streaming.netlify.app) and [community](https://amtins.github.io/cassettator-forbidden-adventures/) playgrounds are available.

#### Pillarbox demo

Use the Pillarbox demo app to test URLs, including DRM-protected streams. Install the iOS and tvOS demo applications via [TestFlight](https://testflight.apple.com/join/TS6ngLqf).

The demo app includes:

- **Playback HUD**: Toggle in settings for detailed playback data.
- **Metrics Debugging View:** Accessible via player settings.

![Demo debugging views](stream-encoding-and-packaging-advice-debugging-views)

### Technical documentation

Refer to the following resources for further details:

- [HTTP Live Streaming](https://developer.apple.com/streaming/).
- [HLS Authoring Specification for Apple Devices](https://developer.apple.com/documentation/http_live_streaming/hls_authoring_specification_for_apple_devices/).
- [RFC 8216](https://tools.ietf.org/html/rfc8216/).
- [Playlist examples](https://developer.apple.com/documentation/http-live-streaming/example-playlists-for-http-live-streaming).
