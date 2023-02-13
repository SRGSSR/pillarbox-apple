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
        expect(mediaComposition.description).to(equal("""
        Dans ce nouvel épisode de YADEBAT, Mélissa réunit 3 couples qui se sont séparés récemment. \
        Elles les a questionné en face à face pour connaître leurs différents ressentis et réactions.
        """))
    }

    func testRedundantMetadata() {
        let mediaComposition = Mock.mediaComposition(.redundant)
        expect(mediaComposition.title).to(equal("February 6, 2023"))
        expect(mediaComposition.subtitle).to(equal("19h30"))
        expect(mediaComposition.description).to(beNil())
    }

    func testLiveMetadata() {
        let mediaComposition = Mock.mediaComposition(.live)
        expect(mediaComposition.title).to(equal("La 1ère en direct"))
        expect(mediaComposition.subtitle).to(beNil())
        expect(mediaComposition.description).to(beNil())
    }
}
