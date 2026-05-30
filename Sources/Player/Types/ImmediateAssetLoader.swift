//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum ImmediateAssetLoader<M>: AssetLoader {
    struct Input {
        let asset: Asset
        let metadata: M
        let mapper: (M) -> PlayerMetadata
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<M, Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: M) -> Asset {
        input.asset
    }

    static func playerMetadata(input: Input, metadata: M) -> PlayerMetadata {
        input.mapper(metadata)
    }
}
