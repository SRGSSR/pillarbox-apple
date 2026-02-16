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
    ///   - decoder: A JSON decoder.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - assetProvider: A closure for creating an `Asset` from a `PlayerData`.
    static func standard<CustomData>(
        request: URLRequest,
        type: CustomData.Type = EmptyCustomData.self,
        decoder: JSONDecoder = JSONDecoder(),
        trackerAdapters: [TrackerAdapter<PlayerData<CustomData>>] = [],
        assetProvider: @escaping (PlayerData<CustomData>) -> Asset<PlayerData<CustomData>>
    ) -> Self where CustomData: Decodable {
        .init(
            publisher: publisher(request: request, type: type, decoder: decoder, assetProvider: assetProvider),
            trackerAdapters: trackerAdapters
        )
    }
}

private extension PlayerItem {
    static func publisher<CustomData>(
        request: URLRequest,
        type: CustomData.Type,
        decoder: JSONDecoder,
        assetProvider: @escaping (PlayerData<CustomData>) -> Asset<PlayerData<CustomData>>,
    ) -> AnyPublisher<Asset<PlayerData<CustomData>>, Error> where CustomData: Decodable {
        URLSession.shared.dataTaskPublisher(for: request)
            .mapHttpErrors()
            .map(\.data)
            .decode(type: PlayerData<CustomData>.self, decoder: decoder)
            .map { assetProvider($0) }
            .eraseToAnyPublisher()
    }
}
