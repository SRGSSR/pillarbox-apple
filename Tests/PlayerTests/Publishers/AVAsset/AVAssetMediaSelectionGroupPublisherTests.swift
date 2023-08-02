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

final class AVAssetMediaSelectionGroupPublisherTests: TestCase {
    func testFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)
        let group = try waitForSingleOutput(from: asset.mediaSelectionGroupPublisher(for: .audible))
        expect(group).notTo(beNil())
    }

    func testFetchWithoutSelectionAvailable() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithoutTracks.url)
        let group = try waitForSingleOutput(from: asset.mediaSelectionGroupPublisher(for: .audible))
        expect(group).to(beNil())
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithTracks.url)

        let group1 = try waitForSingleOutput(from: asset.mediaSelectionGroupPublisher(for: .audible))
        expect(group1).notTo(beNil())

        let group2 = try waitForSingleOutput(from: asset.mediaSelectionGroupPublisher(for: .audible))
        expect(group2).to(equal(group1))
    }

    func testFailedFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.mediaSelectionGroupPublisher(for: .audible))
        expect(error).notTo(beNil())
    }
}
