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
    func testHttpError() {
        expect(DataError.http(withStatusCode: 404)).notTo(beNil())
    }

    func testNotHttpNSError() {
        expect(DataError.http(withStatusCode: 200)).to(beNil())
    }

    @MainActor
    func testErrorLog() async {
        let delegate = FailedResourceLoaderDelegate(error: DataError.blocked(reason: .startDate))
        let player = Player(item: .custom(url: URL.failing, delegate: delegate))
        await expect(player.systemPlayer.currentItem?.errorLog()).toEventuallyNot(beNil())
    }
}
