//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

final class PlayerViewModel {
    var media: Media? {
        didSet {
            guard media != oldValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("--> update media")
                if let playerItem = self.media?.playerItem() {
                    self.player.items = [playerItem]
                }
                else {
                    self.player.removeAllItems()
                }
            }
        }
    }

    let player = Player(configuration: .standard)

    func play() {
        player.becomeActive()
        player.play()
    }
}
