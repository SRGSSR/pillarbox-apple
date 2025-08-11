//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect

final class AVPlayerItemRepeatAllUpdateTests: TestCase {
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
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: previousContents,
            currentItem: nil,
            repeatMode: .all,
            length: .max,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("A"), UUID("B"), UUID("C"), UUID("A")]))
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
        let currentItem = currentItemContent.playerItem(reload: false, configuration: .default, limits: .none)
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: previousContents,
            currentItem: currentItem,
            repeatMode: .all,
            length: .max,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("3"), UUID("B"), UUID("C"), UUID("A")]))
        expect(items.first).to(equal(currentItem))
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
        let currentItem = currentItemContent.playerItem(reload: false, configuration: .default, limits: .none)
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: previousContents,
            currentItem: currentItem,
            repeatMode: .all,
            length: .max,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("3"), UUID("A")]))
        expect(items.first).to(equal(currentItem))
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
        let unknownItem = AssetContent.test(id: "1").playerItem(reload: false, configuration: .default, limits: .none)
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: previousContents,
            currentItem: unknownItem,
            repeatMode: .all,
            length: .max,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("A"), UUID("B"), UUID("A")]))
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
        let currentItem = currentItemContent.playerItem(reload: false, configuration: .default, limits: .none)
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: previousContents,
            currentItem: currentItem,
            repeatMode: .all,
            length: .max,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("2"), UUID("C"), UUID("3")]))
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
        let currentItem = currentItemContent.playerItem(reload: false, configuration: .default, limits: .none)
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: previousContents,
            currentItem: currentItem,
            repeatMode: .all,
            length: .max,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("1"), UUID("2"), UUID("3"), UUID("1")]))
        expect(items.first).to(equal(currentItem))
    }

    func testPlayerItemsLength() {
        let currentContents: [AssetContent] = [
            .test(id: "A"),
            .test(id: "B"),
            .test(id: "C"),
            .test(id: "D")
        ]
        let items = AVPlayerItem.playerItems(
            for: currentContents,
            replacing: [],
            currentItem: nil,
            repeatMode: .all,
            length: 2,
            configuration: .default,
            limits: .none
        )
        expect(items.map(\.id)).to(equalDiff([UUID("A"), UUID("B")]))
    }
}
