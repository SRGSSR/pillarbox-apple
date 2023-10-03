//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import Circumspect
import Combine
import XCTest

private struct Person: Equatable {
    let firstName: String
    let lastName: String
}

final class SlicePublisherTests: XCTestCase {
    func testDelivery() {
        let publisher = [
            Person(firstName: "Jane", lastName: "Doe"),
            Person(firstName: "Jane", lastName: "Smith"),
            Person(firstName: "John", lastName: "Bridges")
        ].publisher.slice(at: \.firstName)
        expectEqualPublished(values: ["Jane", "John"], from: publisher)
    }
}
