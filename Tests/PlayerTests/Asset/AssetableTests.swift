//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class AssetableTests: TestCase {
    func testPlayerItemsWithoutCurrentItem() {
        let previousAssets: [EmptyAsset] = [
            .loading.withId(UUID("1")),
            .loading.withId(UUID("2")),
            .loading.withId(UUID("3")),
            .loading.withId(UUID("4")),
            .loading.withId(UUID("5"))
        ]
        let currentAssets: [EmptyAsset] = [
            .loading.withId(UUID("A")),
            .loading.withId(UUID("B")),
            .loading.withId(UUID("C"))
        ]
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: nil, length: currentAssets.count)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        let currentItemAsset = EmptyAsset.loading.withId(UUID("3"))
        let previousAssets = [
            .loading.withId(UUID("1")),
            .loading.withId(UUID("2")),
            currentItemAsset,
            .loading.withId(UUID("4")),
            .loading.withId(UUID("5"))
        ]
        let currentAssets = [
            .loading.withId(UUID("A")),
            currentItemAsset,
            .loading.withId(UUID("B")),
            .loading.withId(UUID("C"))
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
        let expected = [
            currentItemAsset,
            .loading.withId(UUID("B")),
            .loading.withId(UUID("C"))
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        let currentItemAsset = EmptyAsset.loading.withId(UUID("3"))
        let previousAssets = [
            .loading.withId(UUID("1")),
            .loading.withId(UUID("2")),
            currentItemAsset,
            .loading.withId(UUID("4")),
            .loading.withId(UUID("5"))
        ]
        let currentAssets = [
            .loading.withId(UUID("A")),
            .loading.withId(UUID("B")),
            .loading.withId(UUID("C")),
            currentItemAsset
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
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
            .loading.withId(UUID("1")),
            .loading.withId(UUID("2"))
        ]
        let currentAssets: [EmptyAsset] = [
            .loading.withId(UUID("A")),
            .loading.withId(UUID("B"))
        ]
        let unknownItem = EmptyAsset.loading.withId(UUID("1")).playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: unknownItem, length: currentAssets.count)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        let currentItemAsset = EmptyAsset.loading.withId(UUID("1"))
        let otherAsset = EmptyAsset.loading.withId(UUID("2"))
        let previousAssets = [
            currentItemAsset,
            otherAsset,
            .loading.withId(UUID("3"))
        ]
        let currentAssets = [
            .loading.withId(UUID("3")),
            otherAsset,
            .loading.withId(UUID("C"))
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
        let expected = [
            otherAsset,
            .loading.withId(UUID("C"))
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        let currentItemAsset = EmptyAsset.simple(url: Stream.onDemand.url).withId(UUID("1"))
        let previousAssets: [EmptyAsset] = [
            .loading.withId(UUID("1")),
            .loading.withId(UUID("2")),
            .loading.withId(UUID("3"))
        ]
        let currentAssets = [
            currentItemAsset,
            .loading.withId(UUID("2")),
            .loading.withId(UUID("3"))
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).notTo(equal(currentItem))
    }

    func testPlayerItemsLength() {
        let previousAssets: [EmptyAsset] = [
            .loading.withId(UUID("1")),
            .loading.withId(UUID("2")),
            .loading.withId(UUID("3"))
        ]
        let currentAssets: [EmptyAsset] = [
            .loading.withId(UUID("A")),
            .loading.withId(UUID("B"))
        ]
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: nil, length: 2)
        expect(result.count).to(equal(2))
    }
}
