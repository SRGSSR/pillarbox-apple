//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxCoreBusiness
import PillarboxPlayer

struct Media: Hashable {
    enum `Type`: Hashable {
        case url(URL)
        case unbufferedUrl(URL)
        case urn(String, server: Server)

        static func urn(_ urn: String) -> Self {
            .urn(urn, server: .production)
        }
    }

    let title: String
    let description: String?
    let image: URL?
    let type: `Type`
    let isMonoscopic: Bool

    init(title: String, description: String? = nil, image: URL? = nil, type: `Type`, isMonoscopic: Bool = false) {
        self.title = title
        self.description = description
        self.image = image
        self.type = type
        self.isMonoscopic = isMonoscopic
    }

    init(from template: Template) {
        self.init(
            title: template.title,
            description: template.description,
            image: template.image,
            type: template.type,
            isMonoscopic: template.isMonoscopic
        )
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: self, trackerAdapters: [
                DemoTracker.adapter { media in
                    DemoTracker.Metadata(title: media.title)
                }
            ])
        case let .unbufferedUrl(url):
            return .simple(
                url: url,
                metadata: self,
                trackerAdapters: [
                    DemoTracker.adapter { media in
                        DemoTracker.Metadata(title: media.title)
                    }
                ]
            ) { item in
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
        case let .urn(urn, server: server):
            return .urn(urn, server: server, trackerAdapters: [
                DemoTracker.adapter { metadata in
                    DemoTracker.Metadata(title: metadata.title)
                }
            ])
        }
    }
}

extension Media: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: title, subtitle: description)
    }
}
