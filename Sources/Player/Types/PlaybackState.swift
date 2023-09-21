//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A playback state.
public enum PlaybackState: Equatable {
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

    init(itemState: ItemState, rate: Float) {
        switch itemState {
        case .readyToPlay:
            self = (rate == 0) ? .paused : .playing
        case let .failed(error: error):
            self = .failed(error: error)
        case .ended:
            self = .ended
        case .unknown:
            self = .idle
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended):
            return true
        case let (.failed(error: lhsError), .failed(error: rhsError)):
            return lhsError as NSError == rhsError as NSError
        default:
            return false
        }
    }
}
