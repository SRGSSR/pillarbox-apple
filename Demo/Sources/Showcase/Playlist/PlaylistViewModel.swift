//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import OrderedCollections
import PillarboxPlayer

final class PlaylistViewModel: ObservableObject, PictureInPicturePersistable {
    let player = Player(configuration: .standard)

    var templates: [Template] = [] {
        didSet {
            player.items = Template.medias(from: templates).map { $0.playerItem() }
        }
    }

    var isMonoscopic: Bool {
        false
    }

    func play() {
        player.becomeActive()
        player.play()
    }
}
