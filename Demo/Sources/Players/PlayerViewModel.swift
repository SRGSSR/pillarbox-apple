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
                player = Player(items: [playerItem], configuration: .standard)
            }
            else {
                player.removeAllItems()
            }
        }
    }

    private(set) var player = Player()

    func play() {
        player.becomeActive()
        player.play()
    }
}
