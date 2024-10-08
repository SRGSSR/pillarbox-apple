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

    @Published var layout: PlaybackView.Layout = .minimized

    var items: [PlayerItem] {
        get {
            player.items
        }
        set {
            player.items = newValue
        }
    }

    var isEmpty: Bool {
        player.items.isEmpty
    }

    func add(_ medias: [Media]) {
        medias.forEach { media in
            player.append(media.item())
        }
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    func shuffle() {
        player.items = player.items.shuffled()
    }

    func trash() {
        player.removeAllItems()
    }
}
