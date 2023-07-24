//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Foundation
import Player
import YouTubeIdentifier

struct Media: Hashable, Identifiable {
    enum `Type`: Hashable {
        case url(URL)
        case unbufferedUrl(URL)
        case urn(String, server: Server)
        case youTube(String)

        static func urn(_ urn: String) -> Self {
            .urn(urn, server: .production)
        }
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
            if let youTubeId = Self.youTubeId(from: url) {
                return .youTube(videoId: youTubeId)
            }
            else {
                return .simple(url: url, metadata: self, trackerAdapters: [
                    DemoTracker.adapter { media in
                        DemoTracker.Metadata(title: media.title)
                    }
                ])
            }
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

        case let .youTube(youTubeId):
            return .youTube(videoId: youTubeId)
        }
    }
}

private extension Media {
    static func youTubeId(from url: URL) -> String? {
        YouTubeIdentifier.extract(from: url)
    }
}

extension Media: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: title, subtitle: description)
    }
}
