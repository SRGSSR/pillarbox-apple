//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Foundation
import Player

struct Media: Hashable, Identifiable {
    enum `Type`: Hashable {
        case url(URL)
        case unbufferedUrl(URL)
        case urn(String)
    }

    let id = UUID()
    let title: String
    let description: String?
    let type: `Type`

    init(title: String, description: String? = nil, type: `Type`) {
        self.title = title
        self.description = description
        self.type = type
    }

    init(from template: Template) {
        self.init(
            title: template.title,
            description: template.description,
            type: template.type
        )
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: self, trackers: [
                .init(trackerType: DemoTracker.self, mapper: { media in
                    DemoTracker.Metadata(title: media.title)
                })
            ])
        case let .unbufferedUrl(url):
            return .simple(url: url) { item in
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
        case let .urn(urn):
            return .urn(urn)
        }
    }
}

struct DemoTracker: PlayerItemTracker {
    struct Metadata {
        let title: String
    }

    private let id = UUID()

    func enable(for player: Player) {
        print("--> enable for \(id)")
    }

    func disable() {
        print("--> disable for \(id)")
    }

    func update(with metadata: Metadata) {
        print("--> update metadata for \(id): \(metadata)")
    }
}
