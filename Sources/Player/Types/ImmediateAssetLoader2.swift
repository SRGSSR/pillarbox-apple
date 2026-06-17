//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum ImmediateAssetLoader2: AssetLoader {
    struct Input {
        let asset: Asset
        let metadata: PlayerMetadata
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: PlayerMetadata) -> Asset {
        input.asset
    }

    static func playerMetadata(from input: Input, metadata: PlayerMetadata?) -> PlayerMetadata {
        input.metadata
    }
}
