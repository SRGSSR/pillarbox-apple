//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class AVPlayerItemAssetContentUpdateTests: TestCase {
    func testPlayerItemsWithoutCurrentItem() {
        let previousContents: [AssetContent] = [
            .test(id: "1"),
            .test(id: "2"),
            .test(id: "3"),
            .test(id: "4"),
            .test(id: "5")
        ]
        let currentContents: [AssetContent] = [
            .test(id: "A"),
            .test(id: "B"),
            .test(id: "C")
        ]
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: nil, length: currentContents.count)
        expect(result.count).to(equal(currentContents.count))
        expect(zip(result, currentContents)).to(allPass { item, content in
            content.id == item.id
        })
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        let currentItemContent = AssetContent.test(id: "3")
        let previousContents: [AssetContent] = [
            .test(id: "1"),
            .test(id: "2"),
            currentItemContent,
            .test(id: "4"),
            .test(id: "5")
        ]
        let currentContents = [
            .test(id: "A"),
            currentItemContent,
            .test(id: "B"),
            .test(id: "C")
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        let expected = [
            currentItemContent,
            .test(id: "B"),
            .test(id: "C")
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, content in
            content.id == item.id
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        let currentItemContent = AssetContent.test(id: "3")
        let previousContents = [
            .test(id: "1"),
            .test(id: "2"),
            currentItemContent,
            .test(id: "4"),
            .test(id: "5")
        ]
        let currentContents = [
            .test(id: "A"),
            .test(id: "B"),
            .test(id: "C"),
            currentItemContent
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        let expected = [
            currentItemContent
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, content in
            content.id == item.id
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithUnknownCurrentItem() {
        let previousContents: [AssetContent] = [
            .test(id: "1"),
            .test(id: "2")
        ]
        let currentContents: [AssetContent] = [
            .test(id: "A"),
            .test(id: "B")
        ]
        let unknownItem = AssetContent.test(id: "1").playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: unknownItem, length: currentContents.count)
        expect(result.count).to(equal(currentContents.count))
        expect(zip(result, currentContents)).to(allPass { item, content in
            content.id == item.id
        })
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        let currentItemContent = AssetContent.test(id: "1")
        let otherContent = AssetContent.test(id: "2")
        let previousContents = [
            currentItemContent,
            otherContent,
            .test(id: "3")
        ]
        let currentContents = [
            .test(id: "3"),
            otherContent,
            .test(id: "C")
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        let expected = [
            otherContent,
            .test(id: "C")
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, content in
            content.id == item.id
        })
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        let currentItemContent = AssetContent.test(id: "1")
        let previousContents: [AssetContent] = [
            .test(id: "1"),
            .test(id: "2"),
            .test(id: "3")
        ]
        let currentContents = [
            currentItemContent,
            .test(id: "2"),
            .test(id: "3")
        ]
        let currentItem = currentItemContent.playerItem()
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: currentItem, length: currentContents.count)
        expect(result.count).to(equal(currentContents.count))
        expect(zip(result, currentContents)).to(allPass { item, content in
            content.id == item.id
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsLength() {
        let previousContents: [AssetContent] = [
            .test(id: "1"),
            .test(id: "2"),
            .test(id: "3")
        ]
        let currentContents: [AssetContent] = [
            .test(id: "A"),
            .test(id: "B")
        ]
        let result = AVPlayerItem.playerItems(for: currentContents, replacing: previousContents, currentItem: nil, length: 2)
        expect(result.count).to(equal(2))
    }
}

private extension AssetContent {
    static func test(id: Character) -> Self {
        AssetContent(id: UUID(id), resource: .simple(url: Stream.onDemand.url), metadata: .empty, configuration: .default, metricLog: nil)
    }
}

private extension UUID {
    init(_ char: Character) {
        self.init(
            uuidString: """
                \(String(repeating: char, count: 8))\
                -\(String(repeating: char, count: 4))\
                -\(String(repeating: char, count: 4))\
                -\(String(repeating: char, count: 4))\
                -\(String(repeating: char, count: 12))
                """
        )!
    }
}
