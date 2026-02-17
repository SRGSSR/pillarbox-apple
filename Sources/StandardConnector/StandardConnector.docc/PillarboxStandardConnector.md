# ``PillarboxStandardConnector``

@Metadata {
    @PageColor(blue)
}

Provides a ready-to-use metadata connector.

## Overview

The PillarboxStandardConnector framework provides a standard way to consume media metadata that comply with Pillarbox standard format.
It establishes a clear contract between backends and Pillarbox clients, ensuring consistent metadata decoding.

When creating a standard player item, the connector:

- Performs the HTTP request
- Maps HTTP errors
- Decodes the JSON response into `PlayerData`
- Supports additional metadata through a generic `CustomData` type

> Important: The connector does not create the `Asset` automatically.
> Instead, users must provide an `assetProvider` closure that transforms the decoded `PlayerData` into an `Asset`.

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
        Initialize a player using the standard connector.

        ```swift
        let request = URLRequest(url: URL(string: "http://localhost/media/apple-basic-16-9")!)
        let item = PlayerItem.standard(request: request) { playerData in
            if let source = playerData.source {
                .simple(url: source.url, metadata: playerData)
            }
            else {
                .unavailable(with: NSError(), metadata: playerData)
            }
        }
        let player = Player(item: item)
        ```
    }
}

## Topics

### Content loading

``EmptyCustomData``
``PillarboxPlayer/PlayerItem/standard(request:type:decoder:trackerAdapters:assetProvider:)``
``PlayerData``
``Source``

### Errors

``HttpError``
