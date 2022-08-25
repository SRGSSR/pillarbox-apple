//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

/// Playback states.
public enum PlaybackState {
    /// The player is idle.
    case idle
    /// The player is currently playing content.
    case playing
    /// The player has been paused.
    case paused
    /// The player ended playback of an item.
    case ended
    /// The player encountered an error.
    case failed(error: Error)

    static func publisher(for player: AVPlayer) -> AnyPublisher<PlaybackState, Never> {
        Publishers.CombineLatest(
            ItemState.publisher(for: player),
            ratePublisher(for: player)
        )
        .map { state(for: $0, rate: $1) }
        .removeDuplicates(by: Self.areDuplicates)
        .eraseToAnyPublisher()
    }

    private static func ratePublisher(for player: AVPlayer) -> AnyPublisher<Float, Never> {
        player.publisher(for: \.rate)
            .prepend(player.rate)
            .eraseToAnyPublisher()
    }

    private static func state(for itemState: ItemState, rate: Float) -> PlaybackState {
        switch itemState {
        case .readyToPlay:
            return (rate == 0) ? .paused : .playing
        case let .failed(error: error):
            return .failed(error: error)
        case .ended:
            return .ended
        case .unknown:
            return .idle
        }
    }

    private static func areDuplicates(_ lhsState: PlaybackState, _ rhsState: PlaybackState) -> Bool {
        switch (lhsState, rhsState) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended):
            return true
        default:
            return false
        }
    }
}
