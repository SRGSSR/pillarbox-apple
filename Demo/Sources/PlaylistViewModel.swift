//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

@MainActor
class PlaylistViewModel: ObservableObject {
    let player = Player()
    var currentMedia: Media?

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

    func indexOfCurrentPlayingItem() -> Int? {
        if let item = player.currentItem {
            return player.items.firstIndex(of: item)
        }
        return nil
    }

    func select(_ media: Media) {
        guard
            let playerCurrentItem = player.currentItem,
            let indexOfCurrentPlayingItem = player.items.firstIndex(of: playerCurrentItem),
            let selectIndex = mutableMedias.firstIndex(of: media)
        else { return }

        let shiftCount = abs(selectIndex - indexOfCurrentPlayingItem)
        let isMovingForward = selectIndex > indexOfCurrentPlayingItem

        (0..<shiftCount).forEach { _ in
            _ = isMovingForward ? player.advanceToNextItem() : player.returnToPreviousItem()
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
}
