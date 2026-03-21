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
        let assetProvider: (PlayerData<CustomData>) -> Asset<PlayerData<CustomData>>
    }

    static func publisher(for input: Input) -> AnyPublisher<Asset<PlayerData<CustomData>>, Error> {
        URLSession.shared.dataTaskPublisher(for: input.request)
            .mapHttpErrors()
            .map(\.data)
            .decode(type: PlayerData<CustomData>.self, decoder: input.decoder)
            .map { input.assetProvider($0) }
            .eraseToAnyPublisher()
    }

    static func playerMetadata(from metadata: PlayerData<CustomData>) -> PlayerMetadata {
        metadata.playerMetadata()
    }
}
