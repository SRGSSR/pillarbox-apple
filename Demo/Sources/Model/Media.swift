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
import PillarboxMonitoring
import PillarboxPlayer
import UIKit

struct Media: Hashable {
    enum `Type`: Hashable {
        case url(URL)
        case tokenProtectedUrl(URL)
        case encryptedUrl(URL, certificateUrl: URL)
        case unbufferedUrl(URL)
        case urn(String, serverSetting: ServerSetting)

        static func urn(_ urn: String) -> Self {
            .urn(urn, serverSetting: .ilProduction)
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
            return simplePlayerItem(for: url, configuration: .init(position: at(startTime)))
        case let .tokenProtectedUrl(url):
            return tokenProtectedPlayerItem(for: url, configuration: .init(position: at(startTime)))
        case let .encryptedUrl(url, certificateUrl: certificateUrl):
            return encryptedPlayerItem(for: url, certificateUrl: certificateUrl, configuration: .init(position: at(startTime)))
        case let .unbufferedUrl(url):
            let configuration = PlayerItemConfiguration(
                position: at(startTime),
                automaticallyPreservesTimeOffsetFromLive: true,
                preferredForwardBufferDuration: 1
            )
            return simplePlayerItem(for: url, configuration: configuration)
        case let .urn(urn, serverSetting: serverSetting):
            return .urn(
                urn,
                server: serverSetting.server,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.mediaComposition.mainChapter.title)
                    },
                    MetricsTracker.adapter(configuration: .init(serviceUrl: URL(string: "https://echo.free.beeceptor.com")!)) { metadata in
                        .init(
                            id: metadata.mediaComposition.chapterUrn,
                            metadataUrl: metadata.mediaCompositionUrl,
                            assetUrl: metadata.resource.url
                        )
                    }
                ],
                configuration: .init(position: at(startTime))
            )
        }
    }
}

extension Media {
    private func simplePlayerItem(for url: URL, configuration: PlayerItemConfiguration) -> PlayerItem {
        .simple(
            url: url,
            metadata: Media(title: title, subtitle: subtitle, imageUrl: imageUrl, image: image, type: type, timeRanges: timeRanges),
            trackerAdapters: [
                DemoTracker.adapter { metadata in
                    DemoTracker.Metadata(title: metadata.title)
                }
            ],
            configuration: configuration
        )
    }

    private func tokenProtectedPlayerItem(for url: URL, configuration: PlayerItemConfiguration) -> PlayerItem {
        .tokenProtected(
            url: url,
            metadata: Media(title: title, subtitle: subtitle, imageUrl: imageUrl, image: image, type: type, timeRanges: timeRanges),
            configuration: configuration
        )
    }

    private func encryptedPlayerItem(for url: URL, certificateUrl: URL, configuration: PlayerItemConfiguration) -> PlayerItem {
        .encrypted(
            url: url,
            certificateUrl: certificateUrl,
            metadata: Media(title: title, subtitle: subtitle, imageUrl: imageUrl, image: image, type: type, timeRanges: timeRanges),
            configuration: configuration
        )
    }
}

extension Media: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: title, subtitle: subtitle, imageSource: imageSource, timeRanges: timeRanges)
    }

    private var imageSource: ImageSource {
        if let image {
            return .image(image)
        }
        else if let imageUrl {
            return .url(imageUrl)
        }
        else {
            return .none
        }
    }
}
