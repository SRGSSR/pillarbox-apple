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

@MainActor
final class SourceTests: XCTestCase {
    func testPlayerItemsWithoutCurrentItem() {
        // Given
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

        // When
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: nil)

        // Then
        expect(result.count).to(equal(currentSources.count))
        expect(zip(result, currentSources)).to(allPass({ item, source in
            source.matches(item)
        }))
    }

    func testPlayerItemsWithPreservedCurrentItem() {
        // Given
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

        // When
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)

        // Then
        let expected = [
            currentItemSource,
            Source(id: UUID("B"), asset: .loading),
            Source(id: UUID("C"), asset: .loading)
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass({ item, source in
            source.matches(item)
        }))
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithPreservedCurrentItemAtEnd() {
        // Given
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

        // When
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)

        // Then
        let expected = [
            currentItemSource
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass({ item, source in
            source.matches(item)
        }))
        expect(result.first).to(equal(currentItem))
    }

    func testPlayerItemsWithUnknownCurrentItem() {
        // Given
        let previousSources = [
            Source(id: UUID("1"), asset: .loading),
            Source(id: UUID("2"), asset: .loading)
        ]
        let currentSources = [
            Source(id: UUID("A"), asset: .loading),
            Source(id: UUID("B"), asset: .loading)
        ]
        let unknownItem = Source(id: UUID("1"), asset: .loading).playerItem()

        // When
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: unknownItem)

        // Then
        expect(result.count).to(equal(currentSources.count))
        expect(zip(result, currentSources)).to(allPass({ item, source in
            source.matches(item)
        }))
    }

    func testPlayerItemsWithCurrentItemReplacedByAnotherItem() {
        // Given
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

        // When
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)

        // Then
        let expected = [
            otherSource,
            Source(id: UUID("C"), asset: .loading)
        ]
        expect(result.count).to(equal(expected.count))
        expect(zip(result, expected)).to(allPass({ item, source in
            source.matches(item)
        }))
    }

    func testPlayerItemsWithUpdatedCurrentItem() {
        // Given
        let currentItemSource = Source(id: UUID("1"), asset: .simple(url: Stream.item.url))
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

        // When
        let result = AVPlayerItem.playerItems(for: currentSources, replacing: previousSources, currentItem: currentItem)

        // Then
        expect(result.count).to(equal(currentSources.count))
        expect(zip(result, currentSources)).to(allPass({ item, source in
            source.matches(item)
        }))
        expect(result.first).notTo(equal(currentItem))
    }
}
