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

final class SourceTests: XCTestCase {
    func testSourceEquality() {
        expect(Source(id: UUID("1"), asset: .init(type: .simple(url: Stream.dvr.url))))
            .to(equal(Source(id: UUID("1"), asset: .init(type: .simple(url: Stream.dvr.url)))))
        expect(Source(id: UUID("1"), asset: .init(type: .simple(url: Stream.live.url))))
            .notTo(equal(Source(id: UUID("1"), asset: .init(type: .simple(url: Stream.dvr.url)))))
        expect(Source(id: UUID("1"), asset: .init(type: .simple(url: Stream.dvr.url))))
            .notTo(equal(Source(id: UUID("2"), asset: .init(type: .simple(url: Stream.dvr.url)))))
    }

    func testPlayerItemsWithoutCurrentItem() {
        let previousSources = [
            Source(id: UUID("1"), asset: .loading),
            Source(id: UUID("2"), asset: .loading),
            Source(id: UUID("3"), asset: .loading),
            Source(id: UUID("4"), asset: .loading),
            Source(id: UUID("5"), asset: .loading)
        ]
        let currentSources = [
            Source(id: UUID("A"), asset: .loading),
            Source(id: UUID("B"), asset: .loading),
            Source(id: UUID("C"), asset: .loading)
        ]
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: nil)
        expect(result.count).to(equal(currentSources.count))
        expect(zip(result, currentSources)).to(allPass { item, source in
            source.matches(item)
        })
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        let currentItemSource = Source(id: UUID("3"), asset: .loading)
        let previousSources = [
            Source(id: UUID("1"), asset: .loading),
            Source(id: UUID("2"), asset: .loading),
            currentItemSource,
            Source(id: UUID("4"), asset: .loading),
            Source(id: UUID("5"), asset: .loading)
        ]
        let currentSources = [
            Source(id: UUID("A"), asset: .loading),
            currentItemSource,
            Source(id: UUID("B"), asset: .loading),
            Source(id: UUID("C"), asset: .loading)
        ]
        let currentItem = currentItemSource.playerItem()
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)
        let expected = [
            currentItemSource,
            Source(id: UUID("B"), asset: .loading),
            Source(id: UUID("C"), asset: .loading)
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, source in
            source.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        let currentItemSource = Source(id: UUID("3"), asset: .loading)
        let previousSources = [
            Source(id: UUID("1"), asset: .loading),
            Source(id: UUID("2"), asset: .loading),
            currentItemSource,
            Source(id: UUID("4"), asset: .loading),
            Source(id: UUID("5"), asset: .loading)
        ]
        let currentSources = [
            Source(id: UUID("A"), asset: .loading),
            Source(id: UUID("B"), asset: .loading),
            Source(id: UUID("C"), asset: .loading),
            currentItemSource
        ]
        let currentItem = currentItemSource.playerItem()
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)
        let expected = [
            currentItemSource
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, source in
            source.matches(item)
        })
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithUnknownCurrentItem() {
        let previousSources = [
            Source(id: UUID("1"), asset: .loading),
            Source(id: UUID("2"), asset: .loading)
        ]
        let currentSources = [
            Source(id: UUID("A"), asset: .loading),
            Source(id: UUID("B"), asset: .loading)
        ]
        let unknownItem = Source(id: UUID("1"), asset: .loading).playerItem()
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: unknownItem)
        expect(result.count).to(equal(currentSources.count))
        expect(zip(result, currentSources)).to(allPass { item, source in
            source.matches(item)
        })
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        let currentItemSource = Source(id: UUID("1"), asset: .loading)
        let otherSource = Source(id: UUID("2"), asset: .loading)
        let previousSources = [
            currentItemSource,
            otherSource,
            Source(id: UUID("3"), asset: .loading)
        ]
        let currentSources = [
            Source(id: UUID("3"), asset: .loading),
            otherSource,
            Source(id: UUID("C"), asset: .loading)
        ]
        let currentItem = currentItemSource.playerItem()
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)
        let expected = [
            otherSource,
            Source(id: UUID("C"), asset: .loading)
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass { item, source in
            source.matches(item)
        })
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        let currentItemSource = Source(id: UUID("1"), asset: .init(type: .simple(url: Stream.item.url)))
        let previousSources = [
            Source(id: UUID("1"), asset: .loading),
            Source(id: UUID("2"), asset: .loading),
            Source(id: UUID("3"), asset: .loading)
        ]
        let currentSources = [
            currentItemSource,
            Source(id: UUID("2"), asset: .loading),
            Source(id: UUID("3"), asset: .loading)
        ]
        let currentItem = currentItemSource.playerItem()
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)
        expect(result.count).to(equal(currentSources.count))
        expect(zip(result, currentSources)).to(allPass { item, source in
            source.matches(item)
        })
        expect(result.first).notTo(equal(currentItem))
    }
}
