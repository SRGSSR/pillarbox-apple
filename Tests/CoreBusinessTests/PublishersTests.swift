//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

@_spi(StandardConnectorPrivate)
import PillarboxStandardConnector

import PillarboxCircumspect
import XCTest

final class PublishersTests: XCTestCase {
    func testHttpError() {
        expectFailure(
            HttpError(statusCode: 404),
            from: URLSession(configuration: .default).dataTaskPublisher(for: URL(string: "http://localhost:8123/not_found")!)
                .mapHttpErrors()
        )
    }
}
