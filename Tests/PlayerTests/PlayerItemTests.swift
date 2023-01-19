//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Nimble
import XCTest

final class PlayerItemsTests: XCTestCase {
    func testGenericItem() {
        let asset = Asset(type: .simple(url: Stream.onDemand.url))
        let publisher = Just(asset)
        let item = PlayerItem(publisher: publisher)
        expectAtLeastEqualPublished(
            values: [asset],
            from: item.$source.map(\.asset)
        )
    }

    func testUrlItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectAtLeastSimilarPublished(
            values: [
                Asset(type: .simple(url: Stream.onDemand.url))
            ],
            from: item.$source.map(\.asset)
        )
    }

    func testCustomItemSuccessAsync() {
        let asset = Asset(type: .simple(url: Stream.onDemand.url))
        let publisher = Just(asset)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
        let item = PlayerItem(publisher: publisher)
        expectAtLeastSimilarPublished(
            values: [
                .loading,
                asset
            ],
            from: item.$source.map(\.asset)
        )
    }

    func testCustomItemFailureAsync() {
        let publisher = Fail<Asset, Error>(error: EnumError.error1)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
        let item = PlayerItem(publisher: publisher)
        expectAtLeastSimilarPublished(
            values: [
                .loading,
                .failed(error: EnumError.error1)
            ],
            from: item.$source.map(\.asset)
        )
    }
}
