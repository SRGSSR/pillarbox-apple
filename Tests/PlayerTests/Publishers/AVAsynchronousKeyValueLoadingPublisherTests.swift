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

// swiftlint:disable:next type_name
final class AVAsynchronousKeyValueLoadingPublisherTests: TestCase {
    func testAssetFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let duration = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))
    }

    func testAssetRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)

        let duration1 = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration1).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))

        let duration2 = try waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration2).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))
    }

    func testAssetFailedFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.propertyPublisher(.duration))
        expect(error).notTo(beNil())
    }

    func testAssetMultipleFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let (duration, preferredRate) = try waitForSingleOutput(from: asset.propertyPublisher(.duration, .preferredRate))
        expect(duration).to(equal(Stream.onDemand.duration, by: beClose(within: 1)))
        expect(preferredRate).to(equal(1))
    }

    func testAssetFailedMultipleFetch() throws {
        let asset = AVURLAsset(url: Stream.unavailable.url)
        let error = try waitForFailure(from: asset.propertyPublisher(.duration, .preferredRate))
        expect(error).notTo(beNil())
    }

    func testMetadataItemFetch() throws {
        let item = AVMetadataItem(for: .commonIdentifierTitle, value: "Title")!
        let title = try waitForSingleOutput(from: item.propertyPublisher(.stringValue))
        expect(title).to(equal("Title"))
    }

    func testMetadataItemFetchWithTypeMismatch() throws {
        let item = AVMetadataItem(for: .commonIdentifierTitle, value: "Title")!
        let title = try waitForSingleOutput(from: item.propertyPublisher(.dateValue))
        expect(title).to(beNil())
    }
}
