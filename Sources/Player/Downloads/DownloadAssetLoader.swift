//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

enum DownloadAssetLoader<L>: AssetLoader where L: AssetLoader {
    struct Input {
        let asset: Asset
        let metadata: L.Metadata
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<L.Metadata, Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: L.Metadata) -> Asset {
        input.asset
    }

    static func playerMetadata(from metadata: L.Metadata) -> PlayerMetadata {
        L.playerMetadata(from: metadata)
    }
}
