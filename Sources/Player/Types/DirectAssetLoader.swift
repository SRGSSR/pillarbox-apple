//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum DirectAssetLoader<Provider>: AssetLoader where Provider: AssetProvider {
    struct Input {
        let url: URL
        let configuration: PlaybackConfiguration
        let metadata: AssetMetadata<Provider.CustomData>
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<AssetMetadata<Provider.CustomData>, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: AssetMetadata<Provider.CustomData>) -> Asset {
        Provider.asset(url: input.url, configuration: input.configuration, customData: metadata.customData)
    }

    static func playerMetadata(from input: Input, metadata: AssetMetadata<Provider.CustomData>?) -> PlayerMetadata {
        input.metadata.playerMetadata
    }
}
