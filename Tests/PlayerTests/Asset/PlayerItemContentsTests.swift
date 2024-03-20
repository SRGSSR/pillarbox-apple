//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class PlayerItemContentsTests: TestCase {
    func testPlayerItemsWithoutCurrentItem() {
        let previousContents: [any PlayerItemContent] = [
            AssetContent.test(id: "1"),
            AssetContent.test(id: "2"),
            AssetContent.test(id: "3"),
            AssetContent.test(id: "4"),
            AssetContent.test(id: "5")
        ]
        let currentContents: [any PlayerItemContent] = [
            AssetContent.test(id: "A"),
            AssetContent.test(id: "B"),
            AssetContent.test(id: "C")
        ]
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: nil, length: currentContents.count)
        expect(result.count).to(equal(currentContents.count))
        expect(zip(result, currentContents)).to(allPass { item, content in
            content.matches(item)
        })
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        let currentItemContent = AssetContent.test(id: "3")
        let previousContents = [
            AssetContent.test(id: "1"),
            AssetContent.test(id: "2"),
            currentItemContent,
            AssetContent.test(id: "4"),
            AssetContent.test(id: "5")
        ]
        let currentContents = [
            AssetContent.test(id: "A"),
            currentItemContent,
            AssetContent.test(id: "B"),
            AssetContent.test(id: "C")
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        let expected = [
            currentItemContent,
            AssetContent.test(id: "B"),
            AssetContent.test(id: "C")
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, content in
            content.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        let currentItemContent = AssetContent.test(id: "3")
        let previousContents = [
            AssetContent.test(id: "1"),
            AssetContent.test(id: "2"),
            currentItemContent,
            AssetContent.test(id: "4"),
            AssetContent.test(id: "5")
        ]
        let currentContents = [
            AssetContent.test(id: "A"),
            AssetContent.test(id: "B"),
            AssetContent.test(id: "C"),
            currentItemContent
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        let expected = [
            currentItemContent
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, content in
            content.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithUnknownCurrentItem() {
        let previousContents: [any PlayerItemContent] = [
            AssetContent.test(id: "1"),
            AssetContent.test(id: "2")
        ]
        let currentContents: [any PlayerItemContent] = [
            AssetContent.test(id: "A"),
            AssetContent.test(id: "B")
        ]
        let unknownItem = AssetContent.test(id: "1").playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: unknownItem, length: currentContents.count)
        expect(result.count).to(equal(currentContents.count))
        expect(zip(result, currentContents)).to(allPass { item, content in
            content.matches(item)
        })
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        let currentItemContent = AssetContent.test(id: "1")
        let otherContent = AssetContent.test(id: "2")
        let previousContents = [
            currentItemContent,
            otherContent,
            AssetContent.test(id: "3")
        ]
        let currentContents = [
            AssetContent.test(id: "3"),
            otherContent,
            AssetContent.test(id: "C")
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        let expected = [
            otherContent,
            AssetContent.test(id: "C")
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, content in
            content.matches(item)
        })
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        let currentItemContent = AssetContent.test(id: "1")
        let previousContents: [any PlayerItemContent] = [
            AssetContent.test(id: "1"),
            AssetContent.test(id: "2"),
            AssetContent.test(id: "3")
        ]
        let currentContents = [
            currentItemContent,
            AssetContent.test(id: "2"),
            AssetContent.test(id: "3")
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        expect(result.count).to(equal(currentContents.count))
        expect(zip(result, currentContents)).to(allPass { item, content in
            content.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsLength() {
        let previousContents: [any PlayerItemContent] = [
            AssetContent.test(id: "1"),
            AssetContent.test(id: "2"),
            AssetContent.test(id: "3")
        ]
        let currentContents: [any PlayerItemContent] = [
            AssetContent.test(id: "A"),
            AssetContent.test(id: "B")
        ]
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: nil, length: 2)
        expect(result.count).to(equal(2))
    }
}

private extension AssetContent where M == Void {
    static func test(id: Character) -> any PlayerItemContent {
        let group8 = String(repeating: id, count: 8)
        let group4 = String(repeating: id, count: 4)
        let group12 = String(repeating: id, count: 12)
        return AssetContent(
            asset: .simple(url: Stream.onDemand.url),
            id: UUID(uuidString: "\(group8)-\(group4)-\(group4)-\(group4)-\(group12)")!,
            metadataAdapter: .none(),
            trackerAdapters: []
        )
    }
}
