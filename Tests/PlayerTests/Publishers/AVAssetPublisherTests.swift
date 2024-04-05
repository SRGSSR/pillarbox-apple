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
    func testFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let duration = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)

        let duration1 = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration1).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))

        let duration2 = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration2).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))
    }

    func testFailedFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.propertyPublisher(.duration))
        expect(error).notTo(beNil())
    }

    func testMultipleFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let (duration, preferredRate) = try waitForSingleOutput(from: asset.propertyPublisher(.duration, .preferredRate))
        expect(duration).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))
        expect(preferredRate).to(equal(1))
    }

    func testFailedMultipleFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.propertyPublisher(.duration, .preferredRate))
        expect(error).notTo(beNil())
    }

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
