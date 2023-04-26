//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import XCTest

final class MediaMetadataTests: XCTestCase {
    func testStandardMetadata() {
        let mediaComposition = Mock.mediaComposition(.onDemand)
        let metadata = MediaMetadata(
            mediaComposition: mediaComposition,
            resource: mediaComposition.mainChapter.recommendedResource!,
            image: nil
        )
        expect(metadata.title).to(equal("On réunit des ex après leur rupture"))
        expect(metadata.subtitle).to(equal("Yadebat"))
        expect(metadata.description).to(equal("""
        Dans ce nouvel épisode de YADEBAT, Mélissa réunit 3 couples qui se sont séparés récemment. \
        Elles les a questionné en face à face pour connaître leurs différents ressentis et réactions.
        """))
    }

    func testRedundantMetadata() {
        let mediaComposition = Mock.mediaComposition(.redundant)
        let metadata = MediaMetadata(
            mediaComposition: mediaComposition,
            resource: mediaComposition.mainChapter.recommendedResource!,
            image: nil
        )
        expect(metadata.title).to(equal("February 6, 2023"))
        expect(metadata.subtitle).to(equal("19h30"))
        expect(metadata.description).to(beNil())
    }

    func testLiveMetadata() {
        let mediaComposition = Mock.mediaComposition(.live)
        let metadata = MediaMetadata(
            mediaComposition: mediaComposition,
            resource: mediaComposition.mainChapter.recommendedResource!,
            image: nil
        )
        expect(metadata.title).to(equal("La 1ère en direct"))
        expect(metadata.subtitle).to(beNil())
        expect(metadata.description).to(beNil())
    }

    func testAnalytics() {
        let mediaComposition = Mock.mediaComposition(.onDemand)
        let metadata = MediaMetadata(
            mediaComposition: mediaComposition,
            resource: mediaComposition.mainChapter.recommendedResource!,
            image: nil
        )
        expect(metadata.analyticsData).notTo(beEmpty())
        expect(metadata.analyticsMetadata).notTo(beEmpty())
    }

    func testMissingChapterAnalytics() {
        let mediaComposition = Mock.mediaComposition(.missingAnalytics)
        let metadata = MediaMetadata(
            mediaComposition: mediaComposition,
            resource: mediaComposition.mainChapter.recommendedResource!,
            image: nil
        )
        expect(metadata.analyticsData).to(beEmpty())
        expect(metadata.analyticsMetadata).to(beEmpty())
    }
}
