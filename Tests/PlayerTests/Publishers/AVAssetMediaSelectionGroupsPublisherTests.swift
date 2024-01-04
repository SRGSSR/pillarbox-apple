//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

// swiftlint:disable:next type_name
final class AVAssetMediaSelectionGroupsPublisherTests: TestCase {
    func testFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithOptions.url)
        let groups = try waitForSingleOutput(from: asset.mediaSelectionGroupsPublisher())
        expect(groups[.audible]).notTo(beNil())
        expect(groups[.legible]).notTo(beNil())
    }

    func testFetchWithoutSelectionAvailable() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithoutOptions.url)
        let groups = try waitForSingleOutput(from: asset.mediaSelectionGroupsPublisher())
        expect(groups).to(beEmpty())
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithOptions.url)

        let groups1 = try waitForSingleOutput(from: asset.mediaSelectionGroupsPublisher())
        expect(groups1).notTo(beEmpty())

        let groups2 = try waitForSingleOutput(from: asset.mediaSelectionGroupsPublisher())
        expect(groups2).to(equal(groups1))
    }
}
