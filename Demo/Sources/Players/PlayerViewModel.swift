//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player

final class PlayerViewModel {
    var media: Media? {
        didSet {
            guard media != oldValue else { return }
            if let playerItem = media?.playerItem() {
                player.items = [playerItem]
            }
            else {
                player.removeAllItems()
            }
        }
    }

    let player = Player()

    func play() {
        player.applyConfiguration(.standard)
        player.becomeActive()
        player.play()
    }
}
