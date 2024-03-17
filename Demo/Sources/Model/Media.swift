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

    init(
        title: String,
        subtitle: String? = nil,
        imageUrl: URL? = nil,
        image: UIImage? = nil,
        type: `Type`,
        isMonoscopic: Bool = false,
        startTime: CMTime = .zero
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.image = image
        self.type = type
        self.isMonoscopic = isMonoscopic
        self.startTime = startTime
    }

    init(from template: Template, startTime: CMTime = .zero) {
        self.init(
            title: template.title,
            subtitle: template.subtitle,
            imageUrl: template.imageUrl,
            type: template.type,
            isMonoscopic: template.isMonoscopic,
            startTime: startTime
        )
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            if url.absoluteString.contains("lemanbleu.ch") {
                return PlayerItem.lemanBleu(for: url)
            }
            else {
                return playerItem(for: url) { item in
                    item.seek(at(startTime))
                }
            }
        case let .unbufferedUrl(url):
            return playerItem(for: url) { item in
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
                item.seek(at(startTime))
            }
        case let .urn(urn, server: server):
            return .urn(urn, server: server, trackerAdapters: [
                DemoTracker.adapter { metadata in
                    DemoTracker.Metadata(title: metadata.mediaComposition.mainChapter.title)
                }
            ]) { item in
                item.seek(at(startTime))
            }
        }
    }
}

extension Media {
    private func playerItem(for url: URL, configuration: @escaping (AVPlayerItem) -> Void = { _ in }) -> PlayerItem {
        .init(
            publisher: imagePublisher()
                .map { image in
                    .simple(
                        url: url,
                        metadata: Media(title: title, subtitle: subtitle, image: image, type: type),
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
        .init(title: title, subtitle: subtitle, image: image)
    }
}
