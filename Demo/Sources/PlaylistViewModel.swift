//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Core
import Player
import SwiftUI

@MainActor
class PlaylistViewModel: ObservableObject {
    let player = Player()
    @Published var currentMedia: Media?

    var mutableMedias: [Media] = [] {
        didSet {
            player.items = mutableMedias.compactMap(\.playerItem)
        }
    }
    @Published var medias: [Media] {
        didSet {
            mutableMedias = medias
        }
    }

    // MARK: Init

    init(medias: [Media] = []) {
        self.medias = medias
        configureCurrentItemPublisher()
    }

    // MARK: Internal methods

    func add(_ mediasToAdd: [Media]) {
        let mediasToAdd = mediasToAdd.filter { mutableMedias.contains($0) == false } // Remove item if it's already present into the playlist
        mutableMedias += mediasToAdd
        mediasToAdd.map(\.playerItem).forEach { item in
            if let item {
                player.append(item)
            }
        }
    }

    func shuffle() {
        mutableMedias.shuffle()
        player.removeAllItems()
        mutableMedias.compactMap(\.playerItem).forEach { player.append($0) }
    }

    func reload() {
        mutableMedias = [
            MediaURLPlaylist.videosWithDescription,
            MediaMixturePlaylist.mix1,
            MediaMixturePlaylist.mix2,
            MediaMixturePlaylist.mix3,
        ][Int.random(in: 0...3)]

        player.removeAllItems()
        mutableMedias.compactMap(\.playerItem).forEach { player.append($0) }
    }

    // MARK: Private methods

    func configureCurrentItemPublisher() {
        player.$currentIndex
            .map { [weak self] index in
                guard let self, let index else { return nil }
                return self.mutableMedias[safeIndex: index]
            }
            .assign(to: &$currentMedia)
    }
}
