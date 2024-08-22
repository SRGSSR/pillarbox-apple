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
            if let item = media?.item() {
                player.items = [item]
            }
            else {
                player.removeAllItems()
            }
        }
    }

    @Published var layout: PlaybackView.Layout = .minimized

    let player = Player(configuration: .standard)

    func play() {
        player.becomeActive()
        player.play()
    }
}
