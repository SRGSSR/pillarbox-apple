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
    static func metadataPublisher(for input: AssetLoaderMockInput) -> AnyPublisher<PlayerMetadata, any Error> {
        input.metadataPublisher()
    }

    static func asset(input: AssetLoaderMockInput, metadata: PlayerMetadata) -> Asset {
        input.asset()
    }
}
