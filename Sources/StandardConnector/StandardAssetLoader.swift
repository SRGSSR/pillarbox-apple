//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

enum StandardAssetLoader<CustomData>: AssetLoader where CustomData: Decodable {
    struct Input {
        let request: URLRequest
        let decoder: JSONDecoder
        let assetProvider: (PlayerData<CustomData>) -> Asset
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerData<CustomData>, any Error> {
        URLSession.shared.dataTaskPublisher(for: input.request)
            .mapHttpErrors()
            .map(\.data)
            .decode(type: PlayerData<CustomData>.self, decoder: input.decoder)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerData<CustomData>) -> Asset {
        input.assetProvider(metadata)
    }

    static func playerMetadata(from metadata: PlayerData<CustomData>) -> PlayerMetadata {
        metadata.playerMetadata()
    }
}
