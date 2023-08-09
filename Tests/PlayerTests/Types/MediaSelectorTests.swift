//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import Streams
import XCTest

final class MediaSelectorTests: TestCase {
    func testEmpty() {
        let selector = MediaSelector.empty
        expect(selector.characteristics).to(beEmpty())
        expect(selector.options(for: .legible)).to(beEmpty())
        expect(selector.selectedMediaOption(for: .legible)).to(equal(.disabled))
    }
}
