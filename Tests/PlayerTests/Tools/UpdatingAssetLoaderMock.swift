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

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, Error> {
        Just(.simple(url: input.url, metadata: .init(title: "title1", subtitle: "subtitle1")))
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
            .prepend(.simple(url: input.url, metadata: .init(title: "title0", subtitle: "subtitle0")))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
