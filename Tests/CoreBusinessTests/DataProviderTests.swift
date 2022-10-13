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
            ResourceLoadingError.http(statusCode: 404),
            from: DataProvider().mediaComposition(forUrn: "urn:rts:video:unknown")
        )
    }
}
