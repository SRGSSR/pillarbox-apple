//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

final class PlaylistViewModel: ObservableObject, PictureInPicturePersistable {
    let player = Player(configuration: .standard)

    private var content: [PlayerItem: Media] = [:]

    var medias: [Media] = [] {
        didSet {
            let items = medias.map { $0.item() }
            content = zip(items, medias).reduce(into: [:]) { initial, element in
                initial.updateValue(element.1, forKey: element.0)
            }
            player.items = items
        }
    }

    var isEmpty: Bool {
        medias.isEmpty
    }

    var isMonoscopic: Bool {
        guard let currentItem = player.currentItem, let currentMedia = content[currentItem] else { return false }
        return currentMedia.isMonoscopic
    }

    func media(for item: PlayerItem) -> Media? {
        content[item]
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    func shuffle() {
        player.items = player.items.shuffled()
    }

    func trash() {
        medias = []
    }
}
