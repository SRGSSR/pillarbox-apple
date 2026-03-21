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

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, Error> {
        Fail<Asset<PlayerMetadata>, Error>(error: input.error)
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
