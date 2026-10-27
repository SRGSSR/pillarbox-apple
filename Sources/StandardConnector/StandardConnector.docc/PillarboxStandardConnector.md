# ``PillarboxStandardConnector``

@Metadata {
    @PageColor(blue)
}

Connect to a standard metadata source.

## Overview

The PillarboxStandardConnector framework provides a standard way to consume media metadata that complies with the Pillarbox standard format.
It establishes a clear contract between backends and Pillarbox clients, ensuring consistent metadata decoding.

When creating a standard player item, the connector:

- Performs the HTTP request.
- Maps HTTP errors.
- Decodes the JSON response into `PlayerData`.
- Supports additional metadata through a generic `CustomData` type.

> Important: The connector does not create the `Asset` automatically.
> Instead, implement a ``StandardAssetLoaderProvider`` that describes how to request metadata and how to transform the decoded ``PlayerData`` into an `Asset`.

## Usage

This example shows how to use the standard connector with a backend endpoint and create a player item.

@TabNavigator {
    @Tab("Backend") {
        A hypothetical backend response compliant with the Pillarbox standard format.

        ```json
        {
            "identifier": "apple-basic-16-9",
            "title": "Apple Basic 16:9",
            "subtitle": "16x9 aspect ratio, H.264 @ 30Hz",
            "posterUrl": "https://www.apple.com/newsroom/images/default/apple-logo-og.jpg?202312141200",
            "source": {
                "url": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8",
                "type": "ON-DEMAND"
            },
            "viewport": "STANDARD"
        }
        ```
    }

    @Tab("Frontend") {
        Implement an asset provider and initialize a player using the standard connector.

        ```swift
        enum MediaAssetProvider: StandardAssetLoaderProvider {
            static func request(for input: String) -> URLRequest {
                URLRequest(url: URL(string: "http://localhost/media/\(input)")!)
            }

            static func asset(from input: String, metadata: PlayerData<EmptyCustomData>) -> Asset {
                guard let source = metadata.source else {
                    return .unavailable(with: URLError(.resourceUnavailable))
                }
                return .simple(url: source.url)
            }
        }

        let item = PlayerItem.standard(assetProviderType: MediaAssetProvider.self, input: "apple-basic-16-9")
        let player = Player(item: item)
        ```
    }
}

## Downloads

Standard content can be downloaded for offline playback on iOS 17 and above. Downloads work as described in the [Downloads](https://swiftpackageindex.com/SRGSSR/pillarbox-apple/documentation/pillarboxplayer/downloads-article) article of the PillarboxPlayer framework, with the following differences:

- Use a ``StandardDownloader`` instead of a `Downloader`. It persists downloads with SwiftData, so you don't need to implement a download store.
- Make your asset provider conform to ``StandardAssetDownloadStoreProvider``. Its `Input` and `CustomData` types must be `Codable`.

@TabNavigator {
    @Tab("Provider") {
        Extend the asset provider to identify downloads and play downloaded files.

        ```swift
        extension MediaAssetProvider: StandardAssetDownloadStoreProvider {
            static func id(from input: String) -> String {
                input
            }

            static func asset(fileUrl: URL, customData: EmptyCustomData?) -> Asset {
                .simple(url: fileUrl)
            }
        }
        ```
    }

    @Tab("Downloader") {
        Create a downloader with the provider and add downloads.

        ```swift
        let downloader = try StandardDownloader(
            storeProviderType: MediaAssetProvider.self,
            configuration: .background(withIdentifier: "com.example.downloads")
        )
        downloader.addDownload(for: "apple-basic-16-9")
        ```
    }
}

> Warning: Standard downloaders require a background session configuration, created with [`background(withIdentifier:)`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/background(withidentifier:)). Background configurations support reliable downloading while your app is suspended. Use a different identifier for each downloader.

Metadata is fetched with your provider's request and persisted automatically, including the custom data decoded from ``PlayerData``.

## Topics

### Content Loading

- ``PillarboxPlayer/PlayerItem/standard(assetProviderType:input:trackerAdapters:)``
- ``PlayerData``
- ``StandardAssetLoaderProvider``

### Downloads

- ``StandardAssetDownloadStoreProvider``
- ``StandardDownloader``

### Errors

- ``HttpError``
