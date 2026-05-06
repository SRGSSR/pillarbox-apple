//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

#if DEBUG

struct DemoAssetLoader: AssetLoader {
    struct Input {
        let title: String
        let url: URL
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<String>, any Error> {
        Just(.simple(url: input.url, metadata: input.title))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func playerMetadata(from metadata: String) -> PlayerMetadata {
        .init(title: metadata)
    }
}

#endif
