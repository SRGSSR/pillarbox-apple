//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxCircumspect
import PillarboxCore
import PillarboxStreams

final class PlayerPublisherTests: TestCase {
    private static func bufferingPublisher(for player: Player) -> AnyPublisher<Bool, Never> {
        player.propertiesPublisher
            .slice(at: \.isBuffering)
            .eraseToAnyPublisher()
    }

    private static func presentationSizePublisher(for player: Player) -> AnyPublisher<CGSize?, Never> {
        player.propertiesPublisher
            .slice(at: \.presentationSize)
            .eraseToAnyPublisher()
    }

    private static func itemStatusPublisher(for player: Player) -> AnyPublisher<ItemStatus, Never> {
        player.propertiesPublisher
            .slice(at: \.itemStatus)
            .eraseToAnyPublisher()
    }

    private static func durationPublisher(for player: Player) -> AnyPublisher<CMTime, Never> {
        player.propertiesPublisher
            .slice(at: \.duration)
            .eraseToAnyPublisher()
    }

    private static func seekableTimeRangePublisher(for player: Player) -> AnyPublisher<CMTimeRange, Never> {
        player.propertiesPublisher
            .slice(at: \.seekableTimeRange)
            .eraseToAnyPublisher()
    }

    func testBufferingEmpty() {
        let player = Player()
        expectEqualPublished(
            values: [false],
            from: Self.bufferingPublisher(for: player),
            during: .milliseconds(500)
        )
    }

    func testBuffering() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expectEqualPublished(
            values: [true, false],
            from: Self.bufferingPublisher(for: player),
            during: .milliseconds(500)
        )
    }

    func testPresentationSizeEmpty() {
        let player = Player()
        expectAtLeastEqualPublished(
            values: [nil],
            from: Self.presentationSizePublisher(for: player)
        )
    }

    func testPresentationSize() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), nil],
            from: Self.presentationSizePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testItemStatusEmpty() {
        let player = Player()
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: Self.itemStatusPublisher(for: player)
        )
    }

    func testConsumedItemStatusLifeCycle() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended, .unknown],
            from: Self.itemStatusPublisher(for: player)
        ) {
            player.play()
        }
    }

    func testPausedItemStatusLifeCycle() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: Self.itemStatusPublisher(for: player)
        ) {
            player.actionAtItemEnd = .pause
            player.play()
        }
        expectAtLeastEqualPublishedNext(
            values: [.readyToPlay],
            from: Self.itemStatusPublisher(for: player)
        ) {
            player.seek(to: .zero)
        }
    }

    func testDurationEmpty() {
        let player = Player()
        expectAtLeastPublished(
            values: [.invalid],
            from: Self.durationPublisher(for: player),
            to: beClose(within: 1)
        )
    }

    func testDuration() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastPublished(
            values: [.invalid, Stream.shortOnDemand.duration, .invalid],
            from: Self.durationPublisher(for: player),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }

    func testSeekableTimeRangeEmpty() {
        let player = Player()
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: Self.seekableTimeRangePublisher(for: player)
        )
    }

    func testSeekableTimeRangeLifeCycle() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: Self.seekableTimeRangePublisher(for: player),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }

//    func testMetricEventsPublisher() {
//        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
//        expectAtLeastSimilarPublished(values: [
//            [.init(kind: .assetLoading(.init()))],
//            [.init(kind: .assetLoading(.init())), .init(kind: .resourceLoading(.init()))]
//        ], from: player.metricEventsPublisher) {
//            player.play()
//        }
//    }
}
