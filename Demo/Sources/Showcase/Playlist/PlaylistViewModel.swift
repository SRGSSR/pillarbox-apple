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
    private var cancellables = Set<AnyCancellable>()

    @Published var layout: PlaybackView.Layout = .minimized

    @Published var entries: [PlaylistEntry] = [] {
        didSet {
            player.items = entries.map(\.item)
        }
    }

    @Published var currentEntry: PlaylistEntry? {
        didSet {
            player.currentItem = currentEntry?.item
        }
    }

    var isEmpty: Bool {
        entries.isEmpty
    }

    init() {
        configureCurrentEntryPublisher()
        configureLimitsPublisher()
    }

    func prepend(_ entries: [PlaylistEntry]) {
        self.entries.insert(contentsOf: entries, at: 0)
    }

    func insertBeforeCurrent(_ entries: [PlaylistEntry]) {
        guard let currentEntry, let index = self.entries.firstIndex(of: currentEntry) else { return }
        self.entries.insert(contentsOf: entries, at: index)
    }

    func insertAfterCurrent(_ entries: [PlaylistEntry]) {
        guard let currentEntry, let index = self.entries.firstIndex(of: currentEntry) else { return }
        self.entries.insert(contentsOf: entries, at: self.entries.index(after: index))
    }

    func append(_ entries: [PlaylistEntry]) {
        self.entries.append(contentsOf: entries)
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    func shuffle() {
        entries.shuffle()
    }

    func trash() {
        entries = []
    }

    private func configureCurrentEntryPublisher() {
        Publishers.CombineLatest(player.$currentItem, $entries)
            .map { item, entries in
                entries.first { $0.item == item }
            }
            .assign(to: &$currentEntry)
    }

    private func configureLimitsPublisher() {
        UserDefaults.standard.limitsPublisher()
            .assign(to: \.limits, on: player)
            .store(in: &cancellables)
    }

    private func entry(for item: PlayerItem) -> PlaylistEntry? {
        entries.first { $0.item == item }
    }
}
