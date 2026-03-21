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
        let asset: Asset<PlayerMetadata>
        let delay: TimeInterval
    }

    static func publisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, Error> {
        Just(input.asset)
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
