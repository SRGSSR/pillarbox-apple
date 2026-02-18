//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

public extension PlayerItem {
    /// Creates a player item from a backend endpoint providing Pillarbox-standard metadata.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to fetch metadata from.
    ///   - type: The type of custom metadata to decode. Defaults to `EmptyCustomData`.
    ///   - decoder: A `JSONDecoder` used to decode the response. Defaults to `JSONDecoder()`.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - assetProvider: A closure that receives the decoded `PlayerData` and returns an `Asset`.
    ///
    /// This method fetches metadata from the provided endpoint and decodes it into a `PlayerData` object.
    ///
    /// The connector does not create the `Asset` automatically. Users must provide an `assetProvider` closure that transforms
    /// the decoded `PlayerData` into a playable `Asset`.
    static func standard<CustomData>(
        request: URLRequest,
        type: CustomData.Type,
        decoder: JSONDecoder = JSONDecoder(),
        trackerAdapters: [TrackerAdapter<PlayerData<CustomData>>] = [],
        assetProvider: @escaping (PlayerData<CustomData>) -> Asset<PlayerData<CustomData>>
    ) -> Self where CustomData: Decodable {
        .init(
            publisher: publisher(request: request, type: type, decoder: decoder, assetProvider: assetProvider),
            trackerAdapters: trackerAdapters
        )
    }

    /// Creates a player item from a backend endpoint providing Pillarbox-standard metadata.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to fetch metadata from.
    ///   - decoder: A `JSONDecoder` used to decode the response. Defaults to `JSONDecoder()`.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - assetProvider: A closure that receives the decoded `PlayerData` and returns an `Asset`.
    ///
    /// This method fetches metadata from the provided endpoint and decodes it into a `PlayerData` object.
    ///
    /// The connector does not create the `Asset` automatically. Users must provide an `assetProvider` closure that transforms
    /// the decoded `PlayerData` into a playable `Asset`.
    static func standard(
        request: URLRequest,
        decoder: JSONDecoder = JSONDecoder(),
        trackerAdapters: [TrackerAdapter<PlayerData<EmptyCustomData>>] = [],
        assetProvider: @escaping (PlayerData<EmptyCustomData>) -> Asset<PlayerData<EmptyCustomData>>
    ) -> Self {
        Self.standard(request: request, type: EmptyCustomData.self, decoder: decoder, trackerAdapters: trackerAdapters, assetProvider: assetProvider)
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
