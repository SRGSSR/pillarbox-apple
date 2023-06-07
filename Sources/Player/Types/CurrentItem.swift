//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

enum CurrentItem: Equatable {
    case good(AVPlayerItem?)
    case bad(AVPlayerItem?)

    func smoothPlayerItem(in items: Deque<PlayerItem>) -> AVPlayerItem? {
        switch self {
        case let .bad(playerItem):
            if let lastItem = items.last, lastItem.matches(playerItem) {
                return nil
            }
            else {
                return playerItem
            }
        case let .good(playerItem):
            return playerItem
        }
    }
}
