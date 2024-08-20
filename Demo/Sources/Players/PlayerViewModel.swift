//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

final class PlayerViewModel: ObservableObject, PictureInPicturePersistable {
    @Published var media: Media? {
        didSet {
            guard media != oldValue else { return }
            if let playerItem = media?.item() {
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
