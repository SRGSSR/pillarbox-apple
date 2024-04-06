//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class AVAssetPublisherTests: TestCase {
    func testChapters() throws {
        let asset = AVURLAsset(url: Stream.chaptersMp4.url)
        let chapters = try waitForSingleOutput(from: asset.chaptersPublisher(bestMatchingPreferredLanguages: ["und"]))
        expect(chapters.count).to(equal(4))
    }

    func testWithNonMatchingChapters() throws {
        let asset = AVURLAsset(url: Stream.chaptersMp4.url)
        let chapters = try waitForSingleOutput(from: asset.chaptersPublisher(bestMatchingPreferredLanguages: ["fr"]))
        expect(chapters).to(beEmpty())
    }

    func testWithoutChapters() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let chapters = try waitForSingleOutput(from: asset.chaptersPublisher(bestMatchingPreferredLanguages: ["und"]))
        expect(chapters).to(beEmpty())
    }

    func testChaptersWithFailure() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.chaptersPublisher(bestMatchingPreferredLanguages: ["und"]))
        expect(error).notTo(beNil())
    }
}
