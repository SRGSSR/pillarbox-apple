//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Combine
import Foundation
import PillarboxCoreBusiness
import PillarboxPlayer
import UIKit

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
    let startTime: CMTime

    init(
        title: String,
        description: String? = nil,
        image: URL? = nil,
        type: `Type`,
        isMonoscopic: Bool = false,
        startTime: CMTime = .zero
    ) {
        self.title = title
        self.description = description
        self.image = image
        self.type = type
        self.isMonoscopic = isMonoscopic
        self.startTime = startTime
    }

    init(from template: Template, startTime: CMTime = .zero) {
        self.init(
            title: template.title,
            description: template.description,
            image: template.image,
            type: template.type,
            isMonoscopic: template.isMonoscopic,
            startTime: startTime
        )
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            return .simple(url: url, metadata: self, trackerAdapters: [
                DemoTracker.adapter { media in
                    DemoTracker.Metadata(title: media.title)
                }
            ]) { item in
                item.seek(at(startTime))
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
                item.seek(at(startTime))
            }
        case let .urn(urn, server: server):
            return .urn(urn, server: server, trackerAdapters: [
                DemoTracker.adapter { metadata in
                    DemoTracker.Metadata(title: metadata.title)
                }
            ]) { item in
                item.seek(at(startTime))
            }
        }
    }
}

extension Media: AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init(title: title, subtitle: description)
    }
}
