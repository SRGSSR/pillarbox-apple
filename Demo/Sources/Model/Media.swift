//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
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
    let subtitle: String?
    let imageUrl: URL?
    let image: UIImage?
    let type: `Type`
    let isMonoscopic: Bool
    let startTime: CMTime
    let timeRanges: [TimeRange]

    init(
        title: String,
        subtitle: String? = nil,
        imageUrl: URL? = nil,
        image: UIImage? = nil,
        type: `Type`,
        isMonoscopic: Bool = false,
        startTime: CMTime = .zero,
        timeRanges: [TimeRange] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.image = image
        self.type = type
        self.isMonoscopic = isMonoscopic
        self.startTime = startTime
        self.timeRanges = timeRanges
    }

    init(from template: Template, startTime: CMTime = .zero) {
        self.init(
            title: template.title,
            subtitle: template.subtitle,
            imageUrl: template.imageUrl,
            type: template.type,
            isMonoscopic: template.isMonoscopic,
            startTime: startTime,
            timeRanges: template.timeRanges
        )
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            return playerItem(for: url, configuration: .init(position: at(startTime)))
        case let .unbufferedUrl(url):
            let configuration = PlayerItemConfiguration(
                position: at(startTime),
                automaticallyPreservesTimeOffsetFromLive: true,
                preferredForwardBufferDuration: 1
            )
            return playerItem(for: url, configuration: configuration)
        case let .urn(urn, server: server):
            return .urn(
                urn,
                server: server,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.mediaComposition.mainChapter.title)
                    }
                ],
                configuration: .init(position: at(startTime))
            )
        }
    }
}

extension Media {
    private func playerItem(for url: URL, configuration: PlayerItemConfiguration) -> PlayerItem {
        .init(
            publisher: imagePublisher()
                .map { image in
                    .simple(
                        url: url,
                        metadata: Media(title: title, subtitle: subtitle, image: image, type: type, timeRanges: timeRanges),
                        configuration: configuration
                    )
                },
            trackerAdapters: [
                DemoTracker.adapter { metadata in
                    DemoTracker.Metadata(title: metadata.title)
                }
            ]
        )
    }

    private func imagePublisher() -> AnyPublisher<UIImage?, Never> {
        guard let imageUrl else { return Just(nil).eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: imageUrl)
            .map(\.data)
            .map { UIImage(data: $0) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

extension Media: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: title, subtitle: subtitle, timeRanges: timeRanges)
    }
}
