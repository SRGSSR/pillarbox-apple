//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public final class Player: ObservableObject {
    @Published public private(set) var state: State = .idle

    let player: AVQueuePlayer

    public var items: [AVPlayerItem] {
        player.items()
    }

    public init(items: [AVPlayerItem] = []) {
        player = AVQueuePlayer(items: items)
        Self.statePublisher(for: player)
            .map { State(from: $0) }
            .removeDuplicates { State.areDuplicates(lhsState: $0, rhsState: $1) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }

    public convenience init(item: AVPlayerItem) {
        self.init(items: [item])
    }

    private static func statePublisher(for player: AVPlayer) -> AnyPublisher<PlayerState, Never> {
        Publishers.CombineLatest(
            player.publisher(for: \.currentItem)
                .map { item -> AnyPublisher<ItemState, Never> in
                    guard let item else {
                        return Just(.unknown)
                            .eraseToAnyPublisher()
                    }
                    return ItemState.publisher(for: item)
                }
                .switchToLatest(),
            player.publisher(for: \.rate)
        )
        .map { PlayerState(itemState: $0, rate: $1) }
        .prepend(PlayerState(itemState: .unknown, rate: player.rate))
        .eraseToAnyPublisher()
    }

    public func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        player.insert(item, after: afterItem)
    }

    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    public func remove(_ item: AVPlayerItem) {
        player.remove(item)
    }

    public func removeAllItems() {
        player.removeAllItems()
    }

    public func play() {
        player.play()
    }

    public func pause() {
        player.pause()
    }

    public func togglePlayPause() {
        if player.rate != 0 {
            player.pause()
        }
        else {
            player.play()
        }
    }

    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    @discardableResult
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) async -> Bool {
        await player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    public func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(player: player, interval: interval, queue: queue)
            .eraseToAnyPublisher()
    }
}
