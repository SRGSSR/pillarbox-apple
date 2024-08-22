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
            Self.updated(items: &player.items, from: oldValue, to: medias)
        }
    }

    var isEmpty: Bool {
        medias.isEmpty
    }

    static func updated(items: inout [PlayerItem], from previousMedias: [Media], to currentMedias: [Media]) {
        let changes = currentMedias.difference(from: previousMedias).inferringMoves()
        changes.forEach { change in
            switch change {
            case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                if let associatedWith {
                    items.move(from: associatedWith, to: offset)
                }
                else {
                    items.insert(element.item(), at: offset)
                }
            case let .remove(offset: offset, element: _, associatedWith: _):
                items.remove(at: offset)
            }
        }
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
