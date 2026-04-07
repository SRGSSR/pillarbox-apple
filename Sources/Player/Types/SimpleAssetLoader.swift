//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

enum SimpleAssetLoader: AssetLoader {
    static func assetPublisher(for input: Asset<PlayerMetadata>) -> AnyPublisher<Asset<PlayerMetadata>, Error> {
        Just(input)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func playerMetadata(from metadata: PlayerMetadata) -> PlayerMetadata {
        metadata
    }
}
