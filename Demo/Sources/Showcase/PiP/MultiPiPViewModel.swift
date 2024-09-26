//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

final class MultiPiPViewModel: ObservableObject, PictureInPicturePersistable {
    @Published var media1: Media? {
        didSet {
            guard media1 != oldValue else { return }
            Self.update(player: player1, with: media1)
        }
    }

    @Published var media2: Media? {
        didSet {
            guard media2 != oldValue else { return }
            Self.update(player: player2, with: media2)
        }
    }

    @Published var supportsPictureInPicture1 = true
    @Published var supportsPictureInPicture2 = true

    let player1 = Player(configuration: .externalPlaybackDisabled)
    let player2 = Player(configuration: .externalPlaybackDisabled)

    private static func update(player: Player, with media: Media?) {
        if let item = media?.item() {
            player.items = [item]
        }
        else {
            player.removeAllItems()
        }
    }

    func play() {
        player1.play()
        player2.play()
    }
}
