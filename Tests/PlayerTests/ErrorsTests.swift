//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class ErrorsTests: XCTestCase {
    private enum TestError: LocalizedError {
        case message

        var errorDescription: String? {
            "Message"
        }
    }

    func testLocalizedNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Message"
        ])
        expect(error.localized() as NSError).to(equal(error))
    }

    func testNonLocalizedNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            "NSDescription": "Message"
        ])
        let expectedError = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Message"
        ])
        expect(error.localized() as NSError).to(equal(expectedError))
    }

    func testSwiftError() {
        expect(TestError.message.localized() as NSError).to(equal(TestError.message as NSError))
    }
}
