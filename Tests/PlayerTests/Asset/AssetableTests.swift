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
        let previousAssets: [any Assetable] = [
            AssetContainer.test(id: "1"),
            AssetContainer.test(id: "2"),
            AssetContainer.test(id: "3"),
            AssetContainer.test(id: "4"),
            AssetContainer.test(id: "5")
        ]
        let currentAssets: [any Assetable] = [
            AssetContainer.test(id: "A"),
            AssetContainer.test(id: "B"),
            AssetContainer.test(id: "C")
        ]
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: nil, length: currentAssets.count)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        let currentItemAsset = AssetContainer.test(id: "3")
        let previousAssets = [
            AssetContainer.test(id: "1"),
            AssetContainer.test(id: "2"),
            currentItemAsset,
            AssetContainer.test(id: "4"),
            AssetContainer.test(id: "5")
        ]
        let currentAssets = [
            AssetContainer.test(id: "A"),
            currentItemAsset,
            AssetContainer.test(id: "B"),
            AssetContainer.test(id: "C")
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
        let expected = [
            currentItemAsset,
            AssetContainer.test(id: "B"),
            AssetContainer.test(id: "C")
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        let currentItemAsset = AssetContainer.test(id: "3")
        let previousAssets = [
            AssetContainer.test(id: "1"),
            AssetContainer.test(id: "2"),
            currentItemAsset,
            AssetContainer.test(id: "4"),
            AssetContainer.test(id: "5")
        ]
        let currentAssets = [
            AssetContainer.test(id: "A"),
            AssetContainer.test(id: "B"),
            AssetContainer.test(id: "C"),
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
        let previousAssets: [any Assetable] = [
            AssetContainer.test(id: "1"),
            AssetContainer.test(id: "2")
        ]
        let currentAssets: [any Assetable] = [
            AssetContainer.test(id: "A"),
            AssetContainer.test(id: "B")
        ]
        let unknownItem = AssetContainer.test(id: "1").playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: unknownItem, length: currentAssets.count)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        let currentItemAsset = AssetContainer.test(id: "1")
        let otherAsset = AssetContainer.test(id: "2")
        let previousAssets = [
            currentItemAsset,
            otherAsset,
            AssetContainer.test(id: "3")
        ]
        let currentAssets = [
            AssetContainer.test(id: "3"),
            otherAsset,
            AssetContainer.test(id: "C")
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
        let expected = [
            otherAsset,
            AssetContainer.test(id: "C")
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, asset in
            asset.matches(item)
        })
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        let currentItemAsset = AssetContainer.test(id: "1")
        let previousAssets: [any Assetable] = [
            AssetContainer.test(id: "1"),
            AssetContainer.test(id: "2"),
            AssetContainer.test(id: "3")
        ]
        let currentAssets = [
            currentItemAsset,
            AssetContainer.test(id: "2"),
            AssetContainer.test(id: "3")
        ]
        let currentItem = currentItemAsset.playerItem()
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: currentItem, length: currentAssets.count)
        expect(result.count).to(equal(currentAssets.count))
        expect(zip(result, currentAssets)).to(allPass { item, asset in
            asset.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsLength() {
        let previousAssets: [any Assetable] = [
            AssetContainer.test(id: "1"),
            AssetContainer.test(id: "2"),
            AssetContainer.test(id: "3")
        ]
        let currentAssets: [any Assetable] = [
            AssetContainer.test(id: "A"),
            AssetContainer.test(id: "B")
        ]
        let result = AVPlayerItem.playerItems(for: currentAssets, replacing: previousAssets, currentItem: nil, length: 2)
        expect(result.count).to(equal(2))
    }
}

private extension AssetContainer where M == Void {
    static func test(id: Character) -> any Assetable {
        let group8 = String(repeating: id, count: 8)
        let group4 = String(repeating: id, count: 4)
        let group12 = String(repeating: id, count: 12)
        return AssetContainer(
            asset: .simple(url: Stream.onDemand.url),
            id: UUID(uuidString: "\(group8)-\(group4)-\(group4)-\(group4)-\(group12)")!,
            metadataAdapter: nil,
            trackerAdapters: []
        )
    }
}
