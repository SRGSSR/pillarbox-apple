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

final class AVAssetMediaSelectorPublisherTests: TestCase {
    func testFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)
        let selector = try waitForSingleOutput(from: asset.mediaSelectorPublisher())
        expect(selector.characteristics).notTo(beEmpty())
    }

    func testFetchWithoutSelectionAvailable() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithoutTracks.url)
        let selector = try waitForSingleOutput(from: asset.mediaSelectorPublisher())
        expect(selector.characteristics).to(beEmpty())
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)

        let selector1 = try waitForSingleOutput(from: asset.mediaSelectorPublisher())
        expect(selector1.characteristics).notTo(beEmpty())

        let selections2 = try waitForSingleOutput(from: asset.mediaSelectorPublisher())
        expect(selections2).to(equal(selector1))
    }

    func testFailedFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.mediaSelectorPublisher())
        expect(error).notTo(beNil())
    }
}
