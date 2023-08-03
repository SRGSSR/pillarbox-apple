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
        let groups = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(groups[.audible]).notTo(beNil())
        expect(groups[.legible]).notTo(beNil())
    }

    func testFetchWithoutSelectionAvailable() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithoutTracks.url)
        let groups = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(groups).to(beEmpty())
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)

        let groups1 = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(groups1).notTo(beEmpty())

        let groups2 = try waitForSingleOutput(from: asset.mediaSelectionsPublisher())
        expect(groups2).to(equal(groups1))
    }

    func testFailedFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.mediaSelectionsPublisher())
        expect(error).notTo(beNil())
    }
}
