//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A transition between items in a playlist.
enum ItemTransition: Equatable {
    /// Go to the provided item (or the beginning of the playlist if `nil`).
    case go(to: AVPlayerItem?)
    /// Stop on the provided item.
    case stop(on: AVPlayerItem, with: Error)
    /// Finish playing all items.
    case finish

    var update: ItemUpdate {
        switch self {
        case let .go(to: item):
            return .init(item: item, error: item?.error)
        case let .stop(on: item, with: error):
            return .init(item: item, error: error)
        case .finish:
            return .empty
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.go(to: lhsItem), .go(to: rhsItem)):
            return lhsItem === rhsItem
        case let (.stop(on: lhsItem, with: _), .stop(on: rhsItem, with: _)):
            return lhsItem === rhsItem
        case (.finish, .finish):
            return true
        default:
            return false
        }
    }

    static func transition(from previousUpdate: ItemUpdate, to currentUpdate: ItemUpdate) -> Self {
        if let previousItem = previousUpdate.item, let error = previousUpdate.error {
            return .stop(on: previousItem, with: error)
        }
        else if let currentItem = currentUpdate.item, let error = currentUpdate.error {
            return .stop(on: currentItem, with: error)
        }
        else if let currentItem = currentUpdate.item {
            return .go(to: currentItem)
        }
        else if previousUpdate.item != nil {
            return .finish
        }
        else {
            return .go(to: nil)
        }
    }
}
