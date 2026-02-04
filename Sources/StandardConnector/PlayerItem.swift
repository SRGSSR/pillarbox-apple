//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

public extension PlayerItem {
    /// Creates a player item from a URLRequest.
    /// - Parameters:
    ///   - request: The url request.
    ///   - type: The custom data type.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - configuration: The configuration to apply to the player item.
    static func standard<CustomData: Decodable>(
        request: URLRequest,
        type: CustomData.Type,
        trackerAdapters: [TrackerAdapter<PlayerData<CustomData>>] = [],
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            publisher: publisher(request: request, type: type, configuration: configuration),
            trackerAdapters: trackerAdapters
        )
    }
}

private extension PlayerItem {
    static func publisher<CustomData: Decodable>(
        request: URLRequest,
        type: CustomData.Type,
        configuration: PlaybackConfiguration
    ) -> AnyPublisher<Asset<PlayerData<CustomData>>, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PlayerData<CustomData>.self, decoder: JSONDecoder())
            .map { data in
                Asset.simple(url: data.source.url, metadata: data, configuration: configuration)
            }
            .eraseToAnyPublisher()
    }
}
