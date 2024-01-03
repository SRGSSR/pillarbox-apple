//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import Nimble
import XCTest

final class MediaCompositionTests: XCTestCase {
    func testMainChapter() {
        let mediaComposition = Mock.mediaComposition()
        expect(mediaComposition.mainChapter.urn).to(equal(mediaComposition.chapterUrn))
    }
}
