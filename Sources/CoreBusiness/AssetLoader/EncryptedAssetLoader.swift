//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

enum EncryptedAssetLoader: AssetLoader {
    struct Input {
        let url: URL
        let certificateUrl: URL
        let metadata: PlayerMetadata
        let configuration: PlaybackConfiguration
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerMetadata) -> Asset {
        .encrypted(url: input.url, certificateUrl: input.certificateUrl, configuration: input.configuration)
    }
}
