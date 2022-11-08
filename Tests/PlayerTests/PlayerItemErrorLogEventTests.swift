//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class PlayerItemErrorLogEventTests: XCTestCase {
    func testNoFriendlyComment() {
        expect(AVPlayerItemErrorLogEvent.friendlyComment(from: "The internet connection appears to be offline"))
            .to(equal("The internet connection appears to be offline"))
    }

    func testFriendlyComment() {
        expect(AVPlayerItemErrorLogEvent.friendlyComment(from: "The operation couldn’t be completed. (CoreBusiness.DataError error 1 - This content is not available anymore.)"))
            .to(equal("This content is not available anymore."))
        expect(AVPlayerItemErrorLogEvent.friendlyComment(from: "The operation couldn’t be completed. (CoreBusiness.DataError error 1 - Not found)"))
            .to(equal("Not found"))
        expect(AVPlayerItemErrorLogEvent.friendlyComment(from: "The operation couldn't be completed. (CoreMediaErrorDomain error -16839 - Unable to get playlist before long download timer.)"))
            .to(equal("Unable to get playlist before long download timer."))
    }
}
