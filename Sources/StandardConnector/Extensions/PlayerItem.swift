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
    ///   - request: The URL request.
    ///   - type: The custom data type to decode the response.
    ///   - assetProvider: A closure for creating an `Asset` from a `PlayerData`.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    static func standard<CustomData: Decodable>(
        request: URLRequest,
        type: CustomData.Type = EmptyCustomData.self,
        assetProvider: @escaping (PlayerData<CustomData>) -> Asset<PlayerData<CustomData>>,
        trackerAdapters: [TrackerAdapter<PlayerData<CustomData>>] = [],
    ) -> Self {
        .init(
            publisher: publisher(request: request, type: type, assetProvider: assetProvider),
            trackerAdapters: trackerAdapters
        )
    }
}

private extension PlayerItem {
    static func publisher<CustomData: Decodable>(
        request: URLRequest,
        type: CustomData.Type,
        assetProvider: @escaping (PlayerData<CustomData>) -> Asset<PlayerData<CustomData>>,
    ) -> AnyPublisher<Asset<PlayerData<CustomData>>, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .mapHttpErrors()
            .map(\.data)
            .decode(type: PlayerData<CustomData>.self, decoder: JSONDecoder())
            .map { assetProvider($0) }
            .eraseToAnyPublisher()
    }
}
