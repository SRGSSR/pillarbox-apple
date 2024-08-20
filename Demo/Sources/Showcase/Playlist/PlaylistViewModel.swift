//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import OrderedCollections
import PillarboxPlayer

final class PlaylistViewModel: ObservableObject, PictureInPicturePersistable {
    let player = Player(configuration: .standard)

    private var content: OrderedDictionary<PlayerItem, Media> = [:]

    var medias: [Media] = [] {
        didSet {
            content = medias.reduce(into: [:]) { initial, media in
                initial.updateValue(media, forKey: media.playerItem())
            }
            player.items = content.keys.elements
        }
    }

    var isMonoscopic: Bool {
        false
    }

    func media(for item: PlayerItem) -> Media? {
        content[item]
    }

    func play() {
        player.becomeActive()
        player.play()
    }
}
