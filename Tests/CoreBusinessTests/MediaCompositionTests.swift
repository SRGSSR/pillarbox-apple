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

    func testChapters() {
        let mediaComposition = Mock.mediaComposition(.mixed)
        expect(mediaComposition.chapters.count).to(equal(10))
    }

    func testAudioChapterRemoval() {
        let mediaComposition = Mock.mediaComposition(.audioChapters)
        expect(mediaComposition.chapters).to(beEmpty())
    }
}
