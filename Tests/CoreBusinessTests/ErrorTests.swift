//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness
@testable import PillarboxPlayer

import Nimble
import XCTest

final class ErrorTests: XCTestCase {
    func testErrorLog() {
        let delegate = FailedResourceLoaderDelegate(error: BlockingError(reason: .startDate(nil)))
        let player = Player(item: .custom(url: URL.failing, delegate: delegate))
        expect(player.systemPlayer.currentItem?.errorLog()).toEventuallyNot(beNil())
    }
}
