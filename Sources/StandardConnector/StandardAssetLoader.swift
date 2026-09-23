//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

enum StandardAssetLoader<Provider>: AssetLoader where Provider: StandardAssetLoaderProvider {
    static func metadataPublisher(for input: Provider.Input) -> AnyPublisher<PlayerData<Provider.CustomData>, any Error> {
        URLSession.shared.dataTaskPublisher(for: Provider.request(for: input))
            .mapHttpErrors()
            .map(\.data)
            .decode(type: PlayerData<Provider.CustomData>.self, decoder: Provider.decoder())
            .eraseToAnyPublisher()
    }

    static func asset(from input: Provider.Input, metadata: PlayerData<Provider.CustomData>) -> Asset {
        Provider.asset(from: input, metadata: metadata)
    }

    static func playerMetadata(from input: Provider.Input, metadata: PlayerData<Provider.CustomData>?) -> PlayerMetadata {
        metadata?.playerMetadata() ?? .empty
    }
}
