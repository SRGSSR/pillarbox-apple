//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import OrderedCollections
import Player
import SwiftUI

@MainActor
class PlaylistViewModel: ObservableObject {
    let player = Player()
    @Published var currentMedia: Media? {
        didSet {
            guard
                let currentMedia,
                let index = items.keys.firstIndex(of: currentMedia)
            else { return }
            try? player.setCurrentIndex(index)
        }
    }

    @Published var items = OrderedDictionary<Media, PlayerItem>()

    var medias: [Media] = [] {
        didSet {
            items = Self.updated(initialItems: items, with: medias)
            player.items = items.values.elements
        }
    }

    // MARK: Init

    init() {
        configureCurrentItemPublisher()
    }

    // MARK: Internal methods

    func add(_ mediasToAdd: [Media]) {}

    func shuffle() {
        items.shuffle()
    }

    func reload() {}

    // MARK: Private methods

    private func configureCurrentItemPublisher() {
        player.$currentIndex
            .map { [weak self] index in
                guard let self, let index else { return nil }
                // TODO: Improve the subscript (with `safeIndex:`)
                return self.items.keys[index]
            }
            .assign(to: &$currentMedia)
    }

    private static func updated(initialItems: OrderedDictionary<Media, PlayerItem>, with medias: [Media]) -> OrderedDictionary<Media, PlayerItem> {
        var items = initialItems
        let changes = medias.difference(from: initialItems.keys).inferringMoves()
        changes.forEach { change in
            switch change {
            case .insert(offset: let offset, element: let element, associatedWith: let associatedWith):
                guard let playerItem = element.playerItem else { return }
                if let associatedWith { // move
                    let previousPlayerItem = initialItems.elements[associatedWith].value
                    items.updateValue(previousPlayerItem, forKey: element, insertingAt: offset)
                } else { // insert
                    items.updateValue(playerItem, forKey: element, insertingAt: offset)
                }
            case .remove(offset: let offset, element: _, associatedWith: _):
                items.remove(at: offset)
            }
        }
        return items
    }
}
