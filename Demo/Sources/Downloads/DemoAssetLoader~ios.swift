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

    static func metadataPublisher(for input: Input) -> AnyPublisher<String, any Error> {
        // Use a dummy network connection that might fail in Airplane Mode.
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://httpbin.org/status/200")!)
            .map { _ in input.title }
            .mapError(\.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: String) -> Asset {
        .simple(url: input.url)
    }

    static func playerMetadata(input: Input, metadata: String) -> PlayerMetadata {
        .init(title: metadata)
    }
}

#endif
