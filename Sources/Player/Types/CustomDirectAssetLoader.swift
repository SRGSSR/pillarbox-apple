//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum CustomDirectAssetLoader<CustomData>: AssetLoader {
    struct Input {
        let asset: Asset
        let metadata: AssetMetadata<CustomData>
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<AssetMetadata<CustomData>, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: AssetMetadata<CustomData>) -> Asset {
        input.asset
    }

    static func playerMetadata(from input: Input, metadata: AssetMetadata<CustomData>?) -> PlayerMetadata {
        input.metadata.playerMetadata
    }
}
