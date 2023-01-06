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
    static let standardTemplates = [
        URLTemplate.onDemandVideoHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.onDemandVideoMP4,
        URLTemplate.liveVideoHLS,
        URLTemplate.dvrVideoHLS,
        URLTemplate.liveTimestampVideoHLS,
        URLTemplate.onDemandAudioMP3,
        URLTemplate.liveAudioMP3,
        URNTemplate.onDemandHorizontalVideo,
        URNTemplate.onDemandSquareVideo,
        URNTemplate.onDemandVerticalVideo,
        URNTemplate.liveVideo,
        URNTemplate.dvrVideo,
        URNTemplate.dvrAudio,
        URNTemplate.onDemandAudio,
        URLTemplate.appleBasic_4_3_HLS,
        URLTemplate.appleBasic_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_fMP4_HLS,
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS,
        URNTemplate.tokenProtectedVideo,
        URNTemplate.superfluousTokenProtectedVideo,
        URNTemplate.drmProtectedVideo,
        URNTemplate.expired,
        URNTemplate.unknown
    ]
    var otherStandardTemplates: [Template] {
        Array(OrderedSet(Self.standardTemplates).subtracting(OrderedSet(templates)))
    }

    var templates: [Template] = [] {
        didSet {
            medias = templates.map { $0.media() }
        }
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
            items = Self.updated(initialItems: items, with: newValue)
        }
    }

    // MARK: Init

    init() {
        configureCurrentItemPublisher()
    }

    // MARK: Internal methods

    func add(from templates: [Template]) {
        medias += templates.map { $0.media() }
    }

    func shuffle() {
        items.shuffle()
    }

    func reload() {
        medias = templates.map { $0.media() }
    }

    func trash() {
        medias = []
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
                if let associatedWith { // move
                    let previousPlayerItem = initialItems.elements[associatedWith].value
                    items.updateValue(previousPlayerItem, forKey: element, insertingAt: offset)
                } else { // insert
                    items.updateValue(element.playerItem(), forKey: element, insertingAt: offset)
                }
            case .remove(offset: let offset, element: _, associatedWith: _):
                items.remove(at: offset)
            }
        }
        return items
    }
}
