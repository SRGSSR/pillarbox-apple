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
            from: DataProvider().mediaCompositionPublisher(forUrn: "urn:rts:video:6820736")
        )
    }

    func testNonExistingMediaComposition() {
        expectFailure(
            DataError.http(withStatusCode: 404),
            from: DataProvider().mediaCompositionPublisher(forUrn: "urn:rts:video:unknown")
        )
    }

    func testBlockedMediaComposition() {
        expectFailure(
            DataError.blocked(withMessage: "Some message"),
            from: DataProvider().playableMediaCompositionPublisher(forUrn: "urn:rts:video:13382911")
        )
    }

    func testPartiallyBlockedMediaComposition() {
        expectFailure(
            DataError.blocked(withMessage: "Some message"),
            from: DataProvider().playableMediaCompositionPublisher(forUrn: "urn:srf:video:40ca0277-0e53-4312-83e2-4710354ff53e")
        )
    }
}
