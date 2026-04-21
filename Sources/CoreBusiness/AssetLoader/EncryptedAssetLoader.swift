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
        let context: PlaybackContext
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, any Error> {
        Just(.encrypted(url: input.url, certificateUrl: input.certificateUrl, metadata: input.metadata, configuration: input.context.configuration))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
