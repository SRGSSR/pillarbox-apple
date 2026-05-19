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

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerMetadata) -> Asset {
        .simple(url: input.url, configuration: input.configuration)
    }
}
