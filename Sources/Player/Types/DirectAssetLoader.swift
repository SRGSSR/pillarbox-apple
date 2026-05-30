//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum DirectAssetLoader: AssetLoader {
    struct Input {
        let asset: Asset
        let metadata: PlayerMetadata
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerMetadata) -> Asset {
        input.asset
    }
}
