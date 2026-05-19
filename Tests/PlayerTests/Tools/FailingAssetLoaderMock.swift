//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import PillarboxPlayer

enum FailingAssetLoaderMock: AssetLoader {
    struct Input {
        let error: Error
        let delay: TimeInterval
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        Fail(error: input.error)
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerMetadata) -> Asset {
        .unavailable(with: input.error)
    }
}
