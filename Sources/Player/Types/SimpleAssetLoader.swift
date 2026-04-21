//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum SimpleAssetLoader: AssetLoader {
    struct Input {
        let url: URL
        let metadata: PlayerMetadata
        let configuration: PlaybackConfiguration
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, Error> {
        Just(.simple(url: input.url, metadata: input.metadata, configuration: input.configuration))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func playerMetadata(from metadata: PlayerMetadata) -> PlayerMetadata {
        metadata
    }
}
