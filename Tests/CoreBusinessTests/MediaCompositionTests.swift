//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class MediaCompositionTests: XCTestCase {
    func testMainChapter() {
        let mediaComposition = Mock.mediaComposition()
        expect(mediaComposition.mainChapter.urn).to(equal(mediaComposition.chapterUrn))
    }

    func testStandardMetadata() {
        let mediaComposition = Mock.mediaComposition(.onDemand)
        expect(mediaComposition.title).to(equal("On réunit des ex après leur rupture"))
        expect(mediaComposition.subtitle).to(equal("Yadebat"))
    }

    func testRedundantMetadata() {
        let mediaComposition = Mock.mediaComposition(.redundant)
        expect(mediaComposition.title).to(equal("February 6, 2023"))
        expect(mediaComposition.subtitle).to(equal("19h30"))
    }

    func testLiveMetadata() {
        let mediaComposition = Mock.mediaComposition(.live)
        expect(mediaComposition.title).to(equal("La 1ère en direct"))
        expect(mediaComposition.subtitle).to(beNil())
    }
}
