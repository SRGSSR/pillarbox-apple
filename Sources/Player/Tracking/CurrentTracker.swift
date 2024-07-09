//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class CurrentTracker {
    weak var player: Player?

    init(player: Player) {
        self.player = player
    }
}
