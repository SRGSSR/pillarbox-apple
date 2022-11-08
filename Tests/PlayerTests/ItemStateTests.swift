//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class ItemStateTests: XCTestCase {
    func testEquality() {
        expect(ItemState.unknown).to(equal(.unknown))
        expect(ItemState.readyToPlay).to(equal(.readyToPlay))
        expect(ItemState.ended).to(equal(.ended))
        expect(ItemState.failed(error: StructError())).to(equal(.failed(error: StructError())))
    }

    func testInequality() {
        expect(ItemState.unknown).notTo(equal(.readyToPlay))
        expect(ItemState.failed(error: EnumError.error1)).notTo(equal(.failed(error: EnumError.error2)))
    }

    func testSimilarity() {
        expect(ItemState.unknown).to(equal(.unknown, by: ~=))
        expect(ItemState.readyToPlay).to(equal(.readyToPlay, by: ~=))
        expect(ItemState.ended).to(equal(.ended, by: ~=))
        expect(ItemState.failed(error: StructError())).to(equal(.failed(error: StructError()), by: ~=))
    }

    func testNoFriendlyComment() {
        expect(ItemState.friendlyComment(from: "The internet connection appears to be offline"))
            .to(equal("The internet connection appears to be offline"))
    }

    func testFriendlyComment() {
        expect(ItemState.friendlyComment(from: "The operation couldn’t be completed. (CoreBusiness.DataError error 1 - This content is not available anymore.)"))
            .to(equal("This content is not available anymore."))
        expect(ItemState.friendlyComment(from: "The operation couldn’t be completed. (CoreBusiness.DataError error 1 - Not found)"))
            .to(equal("Not found"))
        expect(ItemState.friendlyComment(from: "The operation couldn't be completed. (CoreMediaErrorDomain error -16839 - Unable to get playlist before long download timer.)"))
            .to(equal("Unable to get playlist before long download timer."))
        expect(ItemState.friendlyComment(from: "L’opération n’a pas pu s’achever. (CoreBusiness.DataError erreur 1 - Ce contenu n'est plus disponible.)"))
            .to(equal("Ce contenu n'est plus disponible."))
    }

    func testLocalizedErrorFromLocalizedNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Error description"
        ])
        expect(ItemState.localizedError(from: error) as NSError).to(equal(error))
    }

    func testLocalizedErrorFromNonLocalizedNSError() {
        let error = NSError(domain: "domain", code: 1012, userInfo: [
            "NSDescription": "Error description"
        ])
        let expectedError = NSError(domain: "domain", code: 1012, userInfo: [
            NSLocalizedDescriptionKey: "Error description"
        ])
        expect(ItemState.localizedError(from: error) as NSError).to(equal(expectedError))
    }

    func testLocalizedErrorFromSwiftError() {
        expect(ItemState.localizedError(from: StructError()) as NSError).to(equal(StructError() as NSError))
    }
}
