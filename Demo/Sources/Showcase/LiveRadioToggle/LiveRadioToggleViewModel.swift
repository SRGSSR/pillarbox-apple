//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

final class LiveRadioToggleViewModel: ObservableObject {
    let player = Player()

    var mode: LiveRadioToggleMode {
        didSet {
            medias = mode.medias
            switchToMedias()
        }
    }

    @Published private(set) var medias: [Media]

    @Published var currentMedia: Media? {
        didSet {
            if let currentMedia, let index = medias.firstIndex(of: currentMedia) {
                player.currentItem = player.items[safeIndex: index]
            }
            else {
                player.currentItem = nil
            }
        }
    }

    init() {
        self.mode = .video
        self.medias = mode.medias
        self.currentMedia = medias.first
        configureCurrentMediaPublisher()
    }

    private func configureCurrentMediaPublisher() {
        player.$currentItem
            .compactMap { [weak self] item -> Media? in
                guard let self, let item, let index = player.items.firstIndex(of: item), let media = medias[safeIndex: index] else {
                    return nil
                }
                return media
            }
            .assign(to: &$currentMedia)
    }

    func play() {
        player.items = medias.map { $0.item() }
        player.play()
    }

    private func switchToMedias() {
        guard let currentItem = player.currentItem, let currentIndex = player.items.firstIndex(of: currentItem) else {
            return
        }
        let position = player.time()
        player.items = medias.map { $0.item() }
        if let playerItem = player.items[safeIndex: currentIndex] {
            player.resume(at(position), in: playerItem)
        }
    }
}
