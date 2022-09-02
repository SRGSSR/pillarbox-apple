//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class AssetPublishersTests: XCTestCase {
    func testFetch() throws {
        let asset = AVURLAsset(url: TestStreams.onDemandUrl)
        let duration = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: TestStreams.onDemandUrl)

        let duration1 = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration1).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))

        let duration2 = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration2).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))
    }

    func testInvalidStream() throws {
        let asset = AVURLAsset(url: TestStreams.unavailableUrl)
        let error = try waitForFailure(from: asset.propertyPublisher(.duration))
        expect(error).notTo(beNil())
    }

    func testMultipleFetch() throws {
        let asset = AVURLAsset(url: TestStreams.onDemandUrl)
        let (duration, preferredRate) = try waitForSingleOutput(from: asset.propertyPublisher(.duration, .preferredRate))
        expect(duration).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))
        expect(preferredRate).to(equal(1))
    }
}
