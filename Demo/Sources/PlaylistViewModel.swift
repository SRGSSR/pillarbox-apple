//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import OrderedCollections
import Player
import SwiftUI

@MainActor
class PlaylistViewModel: ObservableObject {
    static let standardMedias = [
        MediaURL.onDemandVideoHLS,
        MediaURL.shortOnDemandVideoHLS,
        MediaURL.onDemandVideoMP4,
        MediaURL.liveVideoHLS,
        MediaURL.dvrVideoHLS,
        MediaURL.liveTimestampVideoHLS,
        MediaURL.onDemandAudioMP3,
        MediaURL.liveAudioMP3,
        MediaURN.onDemandHorizontalVideo,
        MediaURN.onDemandSquareVideo,
        MediaURN.onDemandVerticalVideo,
        MediaURN.liveVideo,
        MediaURN.dvrVideo,
        MediaURN.dvrAudio,
        MediaURN.onDemandAudio,
        MediaURL.appleBasic_4_3_HLS,
        MediaURL.appleBasic_16_9_TS_HLS,
        MediaURL.appleAdvanced_16_9_TS_HLS,
        MediaURL.appleAdvanced_16_9_fMP4_HLS,
        MediaURL.appleAdvanced_16_9_HEVC_h264_HLS,
        MediaURN.tokenProtectedVideo,
        MediaURN.superfluousTokenProtectedVideo,
        MediaURN.drmProtectedVideo,
        MediaURN.expired,
        MediaURN.unknown,
        Media.empty
    ]
    var initialMedias: [Media] = []
    var availableMedias: [Media] {
        initialMedias + Self.standardMedias
    }

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

    @Published var items = OrderedDictionary<Media, PlayerItem>() {
        didSet {
            player.items = items.values.elements
        }
    }

    var medias: [Media] {
        get {
            Array(items.keys)
        } set {
            if initialMedias.isEmpty {
                initialMedias = newValue
            }
            items = Self.updated(initialItems: items, with: newValue)
        }
    }

    // MARK: Init

    init() {
        configureCurrentItemPublisher()
    }

    // MARK: Internal methods

    func add(_ mediasToAdd: [Media]) {
        medias += mediasToAdd
    }

    func shuffle() {
        items.shuffle()
    }

    func reload() {
        medias = initialMedias
    }

    // MARK: Private methods

    private func configureCurrentItemPublisher() {
        Publishers.CombineLatest(player.$currentIndex, $items)
            .map { index, items in
                guard let index, index < items.count else { return nil }
                // TODO: Improve the subscript (with `safeIndex:`)
                return items.keys[index]
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
