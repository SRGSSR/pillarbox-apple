//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

final class LiveRadioToggleViewModel: ObservableObject {
    let player = Player(configuration: .standard)

    var mode: LiveRadioToggleMode = .video {
        didSet {
            guard let currentItem = player.currentItem, let currentIndex = player.items.firstIndex(of: currentItem) else {
                return
            }
            let position = player.time()
            entries = mode.entries
            if let playerItem = player.items[safeIndex: currentIndex] {
                player.resume(at(position), in: playerItem)
            }
        }
    }

    @Published private(set) var entries: [PlaylistEntry] = [] {
        didSet {
            player.items = entries.map(\.item)
        }
    }

    @Published var currentEntry: PlaylistEntry? {
        didSet {
            player.currentItem = currentEntry?.item
        }
    }

    init() {
        entries = mode.entries
        configureCurrentEntryPublisher()
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    private func configureCurrentEntryPublisher() {
        Publishers.CombineLatest(player.$currentItem, $entries)
            .map { item, entries in
                entries.first { $0.item == item }
            }
            .assign(to: &$currentEntry)
    }
}
