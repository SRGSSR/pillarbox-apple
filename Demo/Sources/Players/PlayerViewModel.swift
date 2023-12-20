//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Player

final class PlayerViewModel: ObservableObject, PictureInPictureSupporting {
    @Published var media: Media? {
        didSet {
            guard media != oldValue else { return }
            print("--> update media")
            if let playerItem = media?.playerItem() {
                player.items = [playerItem]
            }
            else {
                player.removeAllItems()
            }
        }
    }

    let player = Player(configuration: .standard)

    func play() {
        player.becomeActive()
        player.play()
    }
}
