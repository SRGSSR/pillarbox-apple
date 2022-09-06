//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class MediaCompositionTests: XCTestCase {
    func testMediaComposition() {
        let mediaComposition = Mock.mediaComposition()
        expect(mediaComposition).notTo(beNil())
    }
}
