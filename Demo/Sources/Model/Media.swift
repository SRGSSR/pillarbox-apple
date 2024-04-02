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
    let description: String?
    let imageUrl: URL?
    let image: UIImage?
    let type: `Type`
    let isMonoscopic: Bool
    let startTime: CMTime

    init(
        title: String,
        description: String? = nil,
        imageUrl: URL? = nil,
        image: UIImage? = nil,
        type: `Type`,
        isMonoscopic: Bool = false,
        startTime: CMTime = .zero
    ) {
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.image = image
        self.type = type
        self.isMonoscopic = isMonoscopic
        self.startTime = startTime
    }

    init(from template: Template, startTime: CMTime = .zero) {
        self.init(
            title: template.title,
            description: template.description,
            imageUrl: template.imageUrl,
            type: template.type,
            isMonoscopic: template.isMonoscopic,
            startTime: startTime
        )
    }

    func playerItem() -> PlayerItem {
        switch type {
        case let .url(url):
            return playerItem(for: url) { item in
                item.seek(at(startTime))
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
                    DemoTracker.Metadata(title: metadata.title)
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
                        metadata: Media(title: title, description: description, image: image, type: type),
                        configuration: configuration
                    )
                },
            metadataAdapter: StandardMetadata.adapter { metadata in
                .init(
                    title: metadata.title,
                    subtitle: metadata.description,
                    image: metadata.image
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
