//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Circumspect
import XCTest

final class DataProviderTests: XCTestCase {
    func testExistingMediaComposition() {
        expectSuccess(
            from: DataProvider().mediaCompositionPublisher(forUrn: "urn:rts:video:6820736", isStandalone: true)
        )
    }

    func testNonExistingMediaComposition() {
        expectFailure(
            DataError.http(withStatusCode: 404),
            from: DataProvider().mediaCompositionPublisher(forUrn: "urn:rts:video:unknown", isStandalone: true)
        )
    }

    func testBlockedMediaComposition() {
        expectFailure(
            DataError.blocked(withMessage: "This content is not available anymore."),
            from: DataProvider().playableMediaCompositionPublisher(forUrn: "urn:rts:video:13382911", isStandalone: true)
        )
    }
}
