//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Combine
import XCTest

final class ExpectNothingPublishedTests: XCTestCase {
    func testExpectNothingPublished() {
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublished(from: subject, during: .seconds(1))
    }

    func testExpectNothingPublishedNext() {
        let subject = PassthroughSubject<Int, Never>()
        expectNothingPublishedNext(from: subject, during: .seconds(1)) {
            subject.send(4)
        }
    }
}
