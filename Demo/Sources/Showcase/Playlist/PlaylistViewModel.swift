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

    private var medias: OrderedDictionary<PlayerItem, Media> = [:]

    var templates: [Template] = [] {
        didSet {
            medias = Template.medias(from: templates).reduce(into: [:]) { medias, media in
                medias.updateValue(media, forKey: media.playerItem())
            }
            player.items = medias.keys.elements
        }
    }

    var isMonoscopic: Bool {
        false
    }

    func media(for item: PlayerItem) -> Media? {
        medias[item]
    }

    func play() {
        player.becomeActive()
        player.play()
    }
}
