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
final class AVAssetMediaSelectionProviderPublisherTests: TestCase {
    func testFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithOptions.url)
        let provider = try waitForSingleOutput(from: asset.mediaSelectionProviderPublisher())
        expect(provider.group(for: .audible)).notTo(beNil())
        expect(provider.group(for: .legible)).notTo(beNil())
    }

    func testFetchWithoutSelectionAvailable() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithoutOptions.url)
        let provider = try waitForSingleOutput(from: asset.mediaSelectionProviderPublisher())
        expect(provider.characteristics).to(beEmpty())
    }

    func testRepeatedFetch() throws {
        let asset = AVURLAsset(url: Stream.onDemandWithOptions.url)

        let provider1 = try waitForSingleOutput(from: asset.mediaSelectionProviderPublisher())
        expect(provider1.characteristics).notTo(beEmpty())

        let provider2 = try waitForSingleOutput(from: asset.mediaSelectionProviderPublisher())
        expect(provider2).to(equal(provider1))
    }
}
