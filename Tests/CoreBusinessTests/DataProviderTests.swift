//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Circumspect
import XCTest

final class DataProviderTests: XCTestCase {
    func testValidMediaComposition() {
        expectSuccess(
            from: DataProvider().mediaComposition(forUrn: "urn:rts:video:6820736")
        )
    }

    func testNonExistingMediaComposition() {
        expectFailure(
            NSError.httpError(withStatusCode: 404),
            from: DataProvider().mediaComposition(forUrn: "urn:rts:video:unknown")
        )
    }

    func testValidRecommendedResource() {
        expectSuccess(
            from: DataProvider().recommendedResource(forUrn: "urn:rts:video:6820736")
        )
    }
}
