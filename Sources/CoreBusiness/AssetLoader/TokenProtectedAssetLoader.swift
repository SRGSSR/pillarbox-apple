//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

enum TokenProtectedAssetLoader: AssetLoader {
    struct Input {
        let url: URL
        let metadata: PlayerMetadata
        let context: PlaybackContext
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, any Error> {
        Just(.tokenProtected(url: input.url, metadata: input.metadata, configuration: input.context.configuration))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
