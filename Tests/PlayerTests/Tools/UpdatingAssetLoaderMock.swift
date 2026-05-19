//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import PillarboxPlayer

enum UpdatingAssetLoaderMock: AssetLoader {
    struct Input {
        let url: URL
        let delay: TimeInterval
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        Just(.init(title: "title1"))
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .prepend(.init(title: "title0"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(input: Input, metadata: Metadata) -> Asset {
        .simple(url: input.url)
    }
}
