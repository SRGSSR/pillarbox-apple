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

final class AssetableTests: TestCase {
    func testPlayerItemsWithoutCurrentItem() {
        let previousAssets: [EmptyAsset] = [
            .loading.with(UUID("1")),
            .loading.with(UUID("2")),
            .loading.with(UUID("3")),
            .loading.with(UUID("4")),
            .loading.with(UUID("5"))
        ]
        let currentAssets: [EmptyAsset] = [
            .loading.with(UUID("A")),
            .loading.with(UUID("B")),
            .loading.with(UUID("C"))
        ]
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: nil)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        let currentItemAsset = EmptyAsset.loading.with(UUID("3"))
        let previousAssets = [
            .loading.with(UUID("1")),
            .loading.with(UUID("2")),
            currentItemAsset,
            .loading.with(UUID("4")),
            .loading.with(UUID("5"))
        ]
        let currentAssets = [
            .loading.with(UUID("A")),
            currentItemAsset,
            .loading.with(UUID("B")),
            .loading.with(UUID("C"))
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem)
        let expected = [
            currentItemAsset,
            .loading.with(UUID("B")),
            .loading.with(UUID("C"))
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        let currentItemAsset = EmptyAsset.loading.with(UUID("3"))
        let previousAssets = [
            .loading.with(UUID("1")),
            .loading.with(UUID("2")),
            currentItemAsset,
            .loading.with(UUID("4")),
            .loading.with(UUID("5"))
        ]
        let currentAssets = [
            .loading.with(UUID("A")),
            .loading.with(UUID("B")),
            .loading.with(UUID("C")),
            currentItemAsset
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem)
        let expected = [
            currentItemAsset
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithUnknownCurrentItem() {
        let previousAssets: [EmptyAsset] = [
            .loading.with(UUID("1")),
            .loading.with(UUID("2"))
        ]
        let currentAssets: [EmptyAsset] = [
            .loading.with(UUID("A")),
            .loading.with(UUID("B"))
        ]
        let unknownItem = EmptyAsset.loading.with(UUID("1")).playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: unknownItem)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        let currentItemAsset = EmptyAsset.loading.with(UUID("1"))
        let otherAsset = EmptyAsset.loading.with(UUID("2"))
        let previousAssets = [
            currentItemAsset,
            otherAsset,
            .loading.with(UUID("3"))
        ]
        let currentAssets = [
            .loading.with(UUID("3")),
            otherAsset,
            .loading.with(UUID("C"))
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem)
        let expected = [
            otherAsset,
            .loading.with(UUID("C"))
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        let currentItemAsset = EmptyAsset.simple(url: Stream.item.url).with(UUID("1"))
        let previousAssets: [EmptyAsset] = [
            .loading.with(UUID("1")),
            .loading.with(UUID("2")),
            .loading.with(UUID("3"))
        ]
        let currentAssets = [
            currentItemAsset,
            .loading.with(UUID("2")),
            .loading.with(UUID("3"))
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).notTo(equal(currentItem))
    }
}
