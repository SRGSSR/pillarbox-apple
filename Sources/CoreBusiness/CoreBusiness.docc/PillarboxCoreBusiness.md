
# ``PillarboxCoreBusiness``

@Metadata {
    @PageColor(yellow)
}

Play SRG SSR content with the PillarboxPlayer framework.

## Overview

The PillarboxCoreBusiness framework offers standard SRG SSR business integration, most notably:

- **Player items** designed for loading content provided by official SRG SSR backends.
- **Streaming analytics** that adhere to SRG SSR requirements.

> Important: Streaming measurements are automatically captured when playing SRG SSR content using the PillarboxCoreBusiness framework. Ensure that tracking is properly set up beforehand. Refer to the PillarboxAnalytics documentation for more details.

### Play SRG SSR content

To play SRG SSR content, create a `PlayerItem` using ``PillarboxPlayer/PlayerItem/urn(_:server:httpHeaders:trackerAdapters:commandersActSource:)``, and pass the content URN as a parameter. Then load this `PlayerItem` into a `Player` instance.

You can specify a different server or add custom tracker adapters. Standard SRG SSR trackers cannot be disabled.

> Tip: Tracker adapters receive a ``MediaMetadata`` instance as input. If your tracker requires additional data that is not currently available, please submit a corresponding [feature request](https://github.com/SRGSSR/pillarbox-apple/issues/new?assignees=&labels=enhancement%2Ctriage&projects=&template=feature_request.yml).

### Download SRG SSR content

SRG SSR content can be downloaded for offline playback on iOS 17 and above. Downloads work as described in the [Downloads](https://swiftpackageindex.com/SRGSSR/pillarbox-apple/documentation/pillarboxplayer/downloads-article) article of the PillarboxPlayer framework, with the following differences:

- Use a ``URNDownloader`` instead of a `Downloader`. It persists downloads with SwiftData, so you don't need to implement a download store.
- Add downloads with a URN, and optionally a server, using ``URNDownloader/addDownload(urn:server:httpHeaders:configuration:)``. Retrieve an existing download with ``URNDownloader/download(matchingUrn:server:)``.

> Important: URN downloaders persist downloads with [SwiftData](https://developer.apple.com/documentation/swiftdata), which is only available on iOS 17 and above. If your app supports iOS 16, add `SwiftData.framework` to the _Frameworks, Libraries, and Embedded Content_ section of your app target and set its status to _Optional_. Otherwise, your app crashes at launch on iOS 16.

```swift
let downloader = try URNDownloader(configuration: .background(withIdentifier: "com.example.downloads"))
downloader.addDownload(urn: "urn:rts:video:8806923")
```

> Warning: URN downloaders require a background session configuration, created with [`background(withIdentifier:)`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/background(withidentifier:)). Background configurations support reliable downloading while your app is suspended. Use a different identifier for each downloader.

Player items created with ``URNDownloader/playerItem(for:commandersActSource:trackerAdapters:)`` are tracked according to SRG SSR analytics standards, like streamed content. Tracking events may be cached while the device is offline and submitted when connectivity is restored.

### Avoid background playback

comScore regulations prohibit video measurements without a visible video view on the screen.

Do not enable background video playback using `audiovisualBackgroundPlaybackPolicy` on a player loaded with SRG SSR content. Instead, implement proper Picture in Picture (PiP) support to ensure compliance.

## Topics

### Content

- ``PillarboxPlayer/PlayerItem``
- ``Server``

### Downloads

- ``URNDownloader``
- ``URNMetadata``

### Metadata

- ``MediaComposition``
- ``MediaMetadata``
