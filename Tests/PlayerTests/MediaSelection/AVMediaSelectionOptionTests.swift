//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class AVMediaSelectionOptionTests: TestCase {
    func testSortedOptions() {
        let option1 = AVMediaSelectionOptionMock(displayName: "English")
        let option2 = AVMediaSelectionOptionMock(displayName: "French")
        expect(option1 < option2).to(beTrue())
    }

    func testEqualOptions() {
        let option1 = AVMediaSelectionOptionMock(displayName: "English")
        let option2 = AVMediaSelectionOptionMock(displayName: "English")
        expect(option1 < option2).to(beFalse())
    }
}
