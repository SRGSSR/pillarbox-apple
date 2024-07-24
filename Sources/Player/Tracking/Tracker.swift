//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    private let player: AVPlayer

    var item: PlayerItem? {
        willSet {
            item?.disableTrackers(with: .empty, time: .invalid)
        }
        didSet {
            item?.enableTrackers(for: player)
        }
    }

    init(player: AVPlayer) {
        self.player = player
    }

    deinit {
        item?.disableTrackers(with: .empty, time: .invalid)
    }
}
