//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

struct URLAssetLoader: AssetLoader {
    struct Input {
        let title: String
        let url: URL
        let isMonoscopic: Bool

        init(title: String, url: URL, isMonoscopic: Bool = false) {
            self.title = title
            self.url = url
            self.isMonoscopic = isMonoscopic
        }
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<Void, any Error> {
        // Use a dummy network connection that might fail in Airplane Mode.
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://httpbin.org/status/200")!)
            .map { _ in () }
            .mapError(\.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: Void) -> Asset {
        .simple(url: input.url)
    }

    static func playerMetadata(from input: Input, metadata: Void?) -> PlayerMetadata {
        .init(
            title: input.title,
            viewport: input.isMonoscopic ? .monoscopic : .standard
        )
    }
}

#endif
