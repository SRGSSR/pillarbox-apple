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
    private var cancellables = Set<AnyCancellable>()

    @Published var layout: PlaybackView.Layout = .minimized

    @Published private var items = OrderedDictionary<Media, PlayerItem>() {
        didSet {
            player.items = items.values.elements
        }
    }

    @Published var currentMedia: Media? {
        didSet {
            guard let currentMedia, let currentItem = items[currentMedia] else { return }
            player.currentItem = currentItem
        }
    }

    var medias: [Media] {
        get {
            Array(items.keys)
        }
        set {
            items = Self.updated(initialItems: items, with: newValue)
        }
    }

    var isEmpty: Bool {
        player.items.isEmpty
    }

    init() {
        configureCurrentMediaPublisher()
        configureLimitsPublisher()
    }

    private static func updated(
        initialItems: OrderedDictionary<Media, PlayerItem>,
        with medias: [Media]
    ) -> OrderedDictionary<Media, PlayerItem> {
        var items = initialItems
        let changes = medias.difference(from: initialItems.keys).inferringMoves()
        changes.forEach { change in
            switch change {
            case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                if let associatedWith {
                    let previousPlayerItem = initialItems.elements[associatedWith].value
                    items.updateValue(previousPlayerItem, forKey: element, insertingAt: offset)
                }
                else {
                    items.updateValue(element.item(), forKey: element, insertingAt: offset)
                }
            case let .remove(offset: offset, element: _, associatedWith: _):
                items.remove(at: offset)
            }
        }
        return items
    }

    func prepend(_ medias: [Media]) {
        insert(medias, before: nil)
    }

    func insert(_ medias: [Media], before: Media?) {
        if let before {
            guard let beforeIndex = self.medias.firstIndex(of: before) else { return }
            self.medias.insert(contentsOf: medias, at: beforeIndex)
        }
        else {
            self.medias.insert(contentsOf: medias, at: 0)
        }
    }

    func insert(_ medias: [Media], after: Media?) {
        if let after {
            guard let index = self.medias.firstIndex(of: after) else { return }
            self.medias.insert(contentsOf: medias, at: self.medias.index(after: index))
        }
        else {
            self.medias.append(contentsOf: medias)
        }
    }

    func append(_ medias: [Media]) {
        insert(medias, after: nil)
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    func shuffle() {
        items.shuffle()
    }

    func trash() {
        medias = []
    }

    private func configureCurrentMediaPublisher() {
        player.$currentItem
            .map { [weak self] item in
                guard let self, let item else { return nil }
                return media(for: item)
            }
            .assign(to: &$currentMedia)
    }

    private func configureLimitsPublisher() {
        UserDefaults.standard.limitsPublisher()
            .assign(to: \.limits, on: player)
            .store(in: &cancellables)
    }

    private func media(for item: PlayerItem) -> Media? {
        items.first { $0.value == item }?.key
    }
}
