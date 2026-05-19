//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import PillarboxPlayer

enum AssetLoaderMock: AssetLoader {
    struct Input {
        let url: URL
        let metadata: PlayerMetadata
        let delay: TimeInterval

        init(url: URL, metadata: PlayerMetadata, delay: TimeInterval = 0) {
            self.url = url
            self.metadata = metadata
            self.delay = delay
        }
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        Just(input.metadata)
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerMetadata) -> Asset {
        .simple(url: input.url)
    }
}
