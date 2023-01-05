//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble
import XCTest

@MainActor
final class PlayerTests: XCTestCase {
    func testChunkDuration() {
        let item = PlayerItem(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1)],
            from: player.$chunkDuration,
            during: 3
        )
    }

    func testChunkDurationDuringEntirePlayback() {
        let item = PlayerItem(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1), .invalid],
            from: player.$chunkDuration
        ) {
            player.play()
        }
    }

    func testCheckDurationsDuringItemChange() {
        let item1 = PlayerItem(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(
            values: [
                .invalid,
                CMTime(value: 1, timescale: 1),
                .invalid,
                CMTime(value: 4, timescale: 1)
            ],
            from: player.$chunkDuration,
            during: 3
        ) {
            player.play()
        }
    }

    func testDeallocation() {
        let item = PlayerItem(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testItemsWithoutCurrentItem() {
        // Given
        let initial = [
            PlayerItem.Source(id: UUID("1"), asset: .loading),
            PlayerItem.Source(id: UUID("2"), asset: .loading),
            PlayerItem.Source(id: UUID("3"), asset: .loading),
            PlayerItem.Source(id: UUID("4"), asset: .loading),
            PlayerItem.Source(id: UUID("5"), asset: .loading),
        ]
        let final = [
            PlayerItem.Source(id: UUID("A"), asset: .loading),
            PlayerItem.Source(id: UUID("B"), asset: .loading),
            PlayerItem.Source(id: UUID("C"), asset: .loading),
        ]

        // When
        let result = Player.items(initial: initial, final: final, currentItem: nil)

        // Then
        expect(result.map(\.id)).to(equalDiff([UUID("A"), UUID("B"), UUID("C")]))
        expect(result.first?.id).to(equal(UUID("A")))
    }

    func testItemsWithCurrentItemInInitialAndFinal() {
        // Given
        let currentSource = PlayerItem.Source(id: UUID("3"), asset: .loading)
        let initial = [
            PlayerItem.Source(id: UUID("1"), asset: .loading),
            PlayerItem.Source(id: UUID("2"), asset: .loading),
            currentSource,
            PlayerItem.Source(id: UUID("4"), asset: .loading),
            PlayerItem.Source(id: UUID("5"), asset: .loading),
        ]
        let final = [
            PlayerItem.Source(id: UUID("A"), asset: .loading),
            currentSource,
            PlayerItem.Source(id: UUID("B"), asset: .loading),
            PlayerItem.Source(id: UUID("C"), asset: .loading),
        ]
        let currentItem = currentSource.playerItem()

        // When
        let result = Player.items(initial: initial, final: final, currentItem: currentItem)

        // Then
        expect(result.map(\.id)).to(equalDiff([UUID("3"), UUID("B"), UUID("C")]))
        expect(result.first).to(equal(currentItem))
    }

    func testItemsWithCurrentItemInInitialAndFinalAtEnd() {
        // Given
        let currentSource = PlayerItem.Source(id: UUID("3"), asset: .loading)
        let initial = [
            PlayerItem.Source(id: UUID("1"), asset: .loading),
            PlayerItem.Source(id: UUID("2"), asset: .loading),
            currentSource,
            PlayerItem.Source(id: UUID("4"), asset: .loading),
            PlayerItem.Source(id: UUID("5"), asset: .loading),
        ]
        let final = [
            PlayerItem.Source(id: UUID("A"), asset: .loading),
            PlayerItem.Source(id: UUID("B"), asset: .loading),
            PlayerItem.Source(id: UUID("C"), asset: .loading),
            currentSource,
        ]
        let currentItem = currentSource.playerItem()

        // When
        let result = Player.items(initial: initial, final: final, currentItem: currentItem)

        // Then
        expect(result.map(\.id)).to(equalDiff([UUID("3")]))
        expect(result.first).to(equal(currentItem))
    }

    func testItemsWithUnknownCurrentItem() {
        // Given
        let initial = [
            PlayerItem.Source(id: UUID("1"), asset: .loading),
            PlayerItem.Source(id: UUID("2"), asset: .loading),
        ]
        let final = [
            PlayerItem.Source(id: UUID("A"), asset: .loading),
            PlayerItem.Source(id: UUID("B"), asset: .loading),
        ]
        let unknownItem = PlayerItem.Source(id: UUID("1"), asset: .loading).playerItem()

        // When
        let result = Player.items(initial: initial, final: final, currentItem: unknownItem)

        // Then
        expect(result.map(\.id)).to(equalDiff([UUID("A"), UUID("B")]))
        expect(result.first?.id).to(equal(UUID("A")))
    }

    func testItemsWithCurrentItemOnlyInInitialWithGoodCandidate() {
        // Given
        let currentSource = PlayerItem.Source(id: UUID("1"), asset: .loading)
        let candidateSource = PlayerItem.Source(id: UUID("2"), asset: .loading)

        let initial = [
            currentSource,
            candidateSource,
            PlayerItem.Source(id: UUID("3"), asset: .loading),
        ]
        let final = [
            PlayerItem.Source(id: UUID("3"), asset: .loading),
            candidateSource,
            PlayerItem.Source(id: UUID("C"), asset: .loading),
        ]

        let currentItem = currentSource.playerItem()

        // When
        let result = Player.items(initial: initial, final: final, currentItem: currentItem)

        // Then
        expect(result.map(\.id)).to(equalDiff([UUID("2"), UUID("C")]))
        expect(result.first?.id).to(equal(candidateSource.id))
    }

    func testItemsWithUpdatedCurrentItem() {
        // Given
        let currentSource = PlayerItem.Source(id: UUID("1"), asset: .simple(url: Stream.item.url))
        let initial = [
            PlayerItem.Source(id: UUID("1"), asset: .loading),
            PlayerItem.Source(id: UUID("2"), asset: .loading),
            PlayerItem.Source(id: UUID("3"), asset: .loading),
        ]
        let final = [
            currentSource,
            PlayerItem.Source(id: UUID("2"), asset: .loading),
            PlayerItem.Source(id: UUID("3"), asset: .loading),
        ]
        let currentItem = currentSource.playerItem()

        // When
        let result = Player.items(initial: initial, final: final, currentItem: currentItem)

        // Then
        expect(result.map(\.id)).to(equalDiff([UUID("1"), UUID("2"), UUID("3")]))
        expect(result.first).notTo(equal(currentItem))
    }
}
