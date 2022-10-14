//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Circumspect
import XCTest

final class PublishersTests: XCTestCase {
    func testHttpError() {
        expectFailure(
            DataError.http(withStatusCode: 404),
            from: URLSession.shared.dataTaskPublisher(for: URL(string: "http://localhost:8123/not_found")!)
                .mapHttpErrors()
        )
    }
}
