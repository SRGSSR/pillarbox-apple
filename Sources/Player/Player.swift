//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

// MARK: Player

public final class Player: ObservableObject {
    @Published public private(set) var state: State = .idle

    private let player: AVQueuePlayer

    public init(items: [AVPlayerItem] = []) {
        player = AVQueuePlayer(items: items)
    }

    public convenience init(item: AVPlayerItem) {
        self.init(items: [item])
    }

    public var items: [AVPlayerItem] {
        return player.items()
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
}

// MARK: Types

extension Player {
    public enum State: Equatable {
        case idle
        case playing
        case paused
        case ended
        case failed(error: Error)

        public static func == (lhs: Player.State, rhs: Player.State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.playing, .playing), (.paused, .paused),
                (.ended, .ended), (.failed, .failed):
                return true
            default:
                return false
            }
        }
    }
}
