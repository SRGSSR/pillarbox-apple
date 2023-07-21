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
        case urn(String, server: Server)
        case youtube(String)

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
            if let youtubeId = Self.youtubeId(from: url) {
                return .youtube(videoId: youtubeId)
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

        case let .youtube(youtubeId):
            return .youtube(videoId: youtubeId)
        }
    }
}

private extension Media {
    static func youtubeId(from url: URL) -> String? {
        guard
            let component = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = component.host,
            host.contains("youtube") else { return nil }

        return component
            .queryItems?
            .first { $0.name == "v" }?
            .value
    }
}

extension Media: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: title, subtitle: description)
    }
}
