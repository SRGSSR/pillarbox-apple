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
}

extension UUID {
    init(_ char: Character) {
        self.init(uuidString: "\(String(repeating: char, count: 8))-\(String(repeating: char, count: 4))-\(String(repeating: char, count: 4))-\(String(repeating: char, count: 4))-\(String(repeating: char, count: 12))")!
    }
}
