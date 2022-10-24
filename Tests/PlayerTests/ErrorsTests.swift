//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class ErrorsTests: XCTestCase {
    private enum EnumError: LocalizedError {
        case someError

        var errorDescription: String? {
            "Enum error description"
        }

        var failureReason: String? {
            "Enum failure reason"
        }

        var recoverySuggestion: String? {
            "Enum recovery suggestion"
        }

        var helpAnchor: String? {
            "Enum help anchor"
        }
    }

    func testLocalizedNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Error description"
        ])
        expect(error.localized() as NSError).to(equal(error))
    }

    func testNonLocalizedNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            "NSDescription": "Error description"
        ])
        let expectedError = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Error description"
        ])
        expect(error.localized() as NSError).to(equal(expectedError))
    }

    func testSwiftError() {
        expect(EnumError.someError.localized() as NSError).to(equal(EnumError.someError as NSError))
    }

    func testNSErrorFromNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Error description",
            NSLocalizedFailureReasonErrorKey: "Failure reason",
            NSUnderlyingErrorKey: NSError(domain: "inner.domain", code: 2024)
        ])
        expect(NSError.error(from: error)).to(equal(error))
    }

    func testNSErrorFromSwiftError() {
        let error = NSError.error(from: EnumError.someError)!
        expect(error.localizedDescription).to(equal("Enum error description"))
        expect(error.localizedFailureReason).to(equal("Enum failure reason"))
        expect(error.localizedRecoverySuggestion).to(equal("Enum recovery suggestion"))
        expect(error.helpAnchor).to(equal("Enum help anchor"))
    }
}
