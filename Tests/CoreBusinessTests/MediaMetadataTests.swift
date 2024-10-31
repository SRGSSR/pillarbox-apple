//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import Nimble
import XCTest

final class MediaMetadataTests: XCTestCase {
    private static func metadata(_ kind: Mock.MediaCompositionKind) throws -> MediaMetadata {
        try MediaMetadata(
            mediaCompositionResponse: .init(
                mediaComposition: Mock.mediaComposition(kind),
                response: .init()
            ),
            dataProvider: DataProvider()
        )
    }

    func testStandardMetadata() throws {
        let metadata = try Self.metadata(.onDemand)
        expect(metadata.title).to(equal("Yadebat"))
        expect(metadata.subtitle).to(equal("On réunit des ex après leur rupture"))
        expect(metadata.description).to(equal("""
        Dans ce nouvel épisode de YADEBAT, Mélissa réunit 3 couples qui se sont séparés récemment. \
        Elles les a questionné en face à face pour connaître leurs différents ressentis et réactions.
        """))
        expect(metadata.episodeInformation).to(equal(.long(season: 2, episode: 12)))
    }

    func testRedundantMetadata() throws {
        let metadata = try Self.metadata(.redundant)
        expect(metadata.title).to(equal("19h30"))
        expect(metadata.subtitle).to(contain("February"))
        expect(metadata.description).to(beNil())
        expect(metadata.episodeInformation).to(beNil())
    }

    func testLiveMetadata() throws {
        let metadata = try Self.metadata(.live)
        expect(metadata.title).to(equal("La 1ère en direct"))
        expect(metadata.subtitle).to(beNil())
        expect(metadata.description).to(beNil())
        expect(metadata.episodeInformation).to(beNil())
    }

    func testMainChapter() throws {
        let metadata = try Self.metadata(.onDemand)
        expect(metadata.mainChapter.urn).to(equal(metadata.mediaComposition.chapterUrn))
    }

    func testChapters() throws {
        let metadata = try Self.metadata(.mixed)
        expect(metadata.chapters).to(haveCount(10))
    }

    func testAudioChapterRemoval() throws {
        let metadata = try Self.metadata(.audioChapters)
        expect(metadata.chapters).to(beEmpty())
    }

    func testAnalytics() throws {
        let metadata = try Self.metadata(.onDemand)
        expect(metadata.analyticsData).notTo(beEmpty())
        expect(metadata.analyticsMetadata).notTo(beEmpty())
    }

    func testMissingChapterAnalytics() throws {
        let metadata = try Self.metadata(.missingAnalytics)
        expect(metadata.analyticsData).to(beEmpty())
        expect(metadata.analyticsMetadata).to(beEmpty())
    }
}
