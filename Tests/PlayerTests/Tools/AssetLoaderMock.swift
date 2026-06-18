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

    static func asset(from input: AssetLoaderMockInput, metadata: PlayerMetadata) -> Asset {
        input.asset()
    }

    static func playerMetadata(from input: AssetLoaderMockInput, metadata: PlayerMetadata?) -> PlayerMetadata {
        metadata ?? .empty
    }
}
