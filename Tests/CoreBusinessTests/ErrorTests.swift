//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import Combine
import Nimble
import PillarboxPlayer
import XCTest

private enum FailedAssetLoader: AssetLoader {
    static func metadataPublisher(for input: Error) -> AnyPublisher<Void, any Error> {
        Fail(error: input).eraseToAnyPublisher()
    }

    static func asset(input: Error, metadata: Void) -> Asset {
        .unavailable(with: input)
    }

    static func playerMetadata(from metadata: Void) -> PlayerMetadata {
        .empty
    }
}

final class ErrorTests: XCTestCase {
    func testErrorLog() {
        let player = Player(item: .init(assetLoaderType: FailedAssetLoader.self, input: BlockingError(reason: .startDate(nil))))
        expect(player.systemPlayer.currentItem?.errorLog()).toEventuallyNot(beNil())
    }
}
