//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import OrderedCollections
import PillarboxPlayer

final class PlaylistViewModel: ObservableObject, PictureInPicturePersistable {
    static let standardTemplates = [
        URLTemplate.lemanBleuLive,
        URLTemplate.lemanBleu1,
        URLTemplate.lemanBleu2,
        URLTemplate.lemanBleu3,
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
        URLTemplate.appleBasic_4_3_HLS,
        URLTemplate.appleBasic_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_fMP4_HLS,
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS,
        URLTemplate.appleWWDCKeynote2023,
        URLTemplate.appleDolbyAtmos,
        URLTemplate.appleTvMorningShowSeason1Trailer,
        URLTemplate.appleTvMorningShowSeason2Trailer,
        URLTemplate.uhdVideoHLS,
        URNTemplate.gothard_360,
        URLTemplate.bitmovin_360,
        URLTemplate.unauthorized,
        URLTemplate.unknown,
        URLTemplate.unavailableMp3,
        URNTemplate.expired,
        URNTemplate.unknown
    ]

    @Published var currentMedia: Media? {
        didSet {
            guard let currentMedia, let index = items.keys.firstIndex(of: currentMedia) else { return }
            if player.currentIndex != index {
                try? player.setCurrentIndex(index)
            }
            else {
                player.skipToDefault()
            }
        }
    }

    @Published private var items = OrderedDictionary<Media, PlayerItem>() {
        didSet {
            player.items = items.values.elements
        }
    }

    let player = Player(configuration: .standard)

    var medias: [Media] {
        get {
            Array(items.keys)
        }
        set {
            items = Self.updated(initialItems: items, with: newValue)
        }
    }

    var otherStandardTemplates: [Template] {
        Array(OrderedSet(Self.standardTemplates).subtracting(OrderedSet(templates)))
    }

    var templates: [Template] = [] {
        didSet {
            guard medias.isEmpty else { return }
            medias = Template.medias(from: templates)
        }
    }

    var isEmpty: Bool {
        medias.isEmpty
    }

    var isMonoscopic: Bool {
        currentMedia?.isMonoscopic ?? false
    }

    var canReload: Bool {
        !templates.isEmpty
    }

    init() {
        configureCurrentItemPublisher()
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
                    items.updateValue(element.playerItem(), forKey: element, insertingAt: offset)
                }
            case let .remove(offset: offset, element: _, associatedWith: _):
                items.remove(at: offset)
            }
        }
        return items
    }

    func add(from templates: [Template]) {
        medias += Template.medias(from: templates)
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    func shuffle() {
        items.shuffle()
    }

    func reload() {
        medias = Template.medias(from: templates)
    }

    func trash() {
        medias = []
    }

    private func configureCurrentItemPublisher() {
        Publishers.CombineLatest(player.$currentIndex, $items)
            .map { index, items in
                guard let index, index < items.count else { return nil }
                return items.keys[index]
            }
            .assign(to: &$currentMedia)
    }
}
