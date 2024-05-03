//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import PillarboxCircumspect
import XCTest

final class PublishersTests: XCTestCase {
    func testHttpError() {
        expectFailure(
            DataError.http(withStatusCode: 404),
            from: URLSession(configuration: .default).dataTaskPublisher(for: URL(string: "http://localhost:8123/not_found")!)
                .mapHttpErrors()
        )
    }
}
