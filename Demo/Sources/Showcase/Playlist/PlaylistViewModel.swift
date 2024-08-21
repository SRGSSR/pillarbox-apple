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

    var medias: [Media] = [] {
        didSet {
            // TODO: Skip if identical for correct PIP restoration
            player.items = medias.map { $0.item() }
        }
    }

    var isEmpty: Bool {
        medias.isEmpty
    }

    var isMonoscopic: Bool {
        // FIXME:
        false
    }

    func add(_ medias: [Media]) {
        self.medias += medias
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
