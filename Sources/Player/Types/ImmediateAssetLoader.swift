//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum ImmediateAssetLoader<CustomData>: AssetLoader {
    struct Input {
        let asset: Asset
        let metadata: PlayerMetadata
        let customData: CustomData
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<CustomData, any Error> {
        Just(input.customData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: CustomData) -> Asset {
        input.asset
    }

    static func playerMetadata(from input: Input, metadata: CustomData?) -> PlayerMetadata {
        input.metadata
    }
}
