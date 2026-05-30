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

    static func metadataPublisher(for input: Input) -> AnyPublisher<M, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: M) -> Asset {
        input.asset
    }

    static func playerMetadata(from input: Input, metadata: M?) -> PlayerMetadata {
        guard let metadata else { return .empty }
        return input.mapper(metadata)
    }
}
