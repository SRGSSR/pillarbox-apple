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

final class AVAssetMediaSelectionsPublisherTests: TestCase {
    func testFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)
        let selections = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(selections.characteristics).notTo(beEmpty())
    }

    func testFetchWithoutSelectionAvailable() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithoutTracks.url)
        let selections = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(selections.characteristics).to(beEmpty())
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)

        let selections1 = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(selections1.characteristics).notTo(beEmpty())

        let selections2 = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(selections2).to(equal(selections1))
    }

    func testFailedFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.mediaSelectionsPublisher())
        expect(error).notTo(beNil())
    }
}
