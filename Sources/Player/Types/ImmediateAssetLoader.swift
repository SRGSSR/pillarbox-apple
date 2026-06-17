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
        let metadata: DownloadMetadata<CustomData>
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<DownloadMetadata<CustomData>, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: DownloadMetadata<CustomData>) -> Asset {
        input.asset
    }

    static func playerMetadata(from input: Input, metadata: DownloadMetadata<CustomData>?) -> PlayerMetadata {
        input.metadata.playerMetadata
    }
}
