//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import PillarboxPlayer

enum UnavailableAssetLoaderMock: AssetLoader {
    struct Input {
        let error: Error
        let metadata: PlayerMetadata
        let delay: TimeInterval
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        Just(input.metadata)
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: PlayerMetadata) -> Asset {
        .unavailable(with: input.error)
    }
}
