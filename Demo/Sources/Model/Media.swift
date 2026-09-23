//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
import Foundation
import PillarboxPlayer
import UIKit

@_spi(CoreBusinessPrivate)
import PillarboxCoreBusiness

struct Media: Hashable {
    enum Kind: Hashable {
        case url(URL, customData: MediaCustomData)
        case urn(String, serverSetting: ServerSetting)
        case demo(String, isProduction: Bool)
        case item(PlayerItem)

        static func url(_ url: URL, protection: Protection = .none, startTime: CMTime = .zero, isBuffered: Bool = true) -> Self {
            .url(url, customData: .init(protection: protection, startTime: startTime, isBuffered: isBuffered))
        }

        static func urn(_ urn: String) -> Self {
            .urn(urn, serverSetting: .production)
        }
    }

    let title: String
    let subtitle: String?
    let imageUrl: URL?
    let image: UIImage?
    let kind: Kind
    let viewport: Viewport
    let timeRanges: [TimeRange]

    init(
        title: String,
        subtitle: String? = nil,
        imageUrl: URL? = nil,
        image: UIImage? = nil,
        kind: Kind,
        viewport: Viewport = .standard,
        timeRanges: [TimeRange] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.image = image
        self.kind = kind
        self.viewport = viewport
        self.timeRanges = timeRanges
    }

    func item() -> PlayerItem {
        switch kind {
        case let .url(url, customData: customData):
            return .custom(
                assetProviderType: MediaAssetProvider.self,
                url: url,
                metadata: metadata(customData: customData),
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.title)
                    }
                ]
            )
        case let .urn(urn, serverSetting: serverSetting):
            return .urn(
                urn,
                server: serverSetting.server,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.mainChapter.title)
                    }
                ]
            )
        case let .demo(identifier, isProduction: isProduction):
            return .standard(assetProviderType: DemoAssetProvider.self, input: .init(identifier: identifier, isProduction: isProduction))
        case let .item(item):
            return item
        }
    }

    func playerItem() -> AVPlayerItem? {
        switch kind {
        case let .url(url, customData: customData):
            let item = AVPlayerItem(url: url)
            if !customData.isBuffered {
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
            return item
        default:
            return nil
        }
    }
}

extension Media {
    private var imageSource: ImageSource {
        if let image, let data = image.jpegData(compressionQuality: 1) {
            return .image(data)
        }
        else if let imageUrl {
            return .url(standardResolution: imageUrl)
        }
        else {
            return .none
        }
    }

    func metadata(customData: MediaCustomData) -> AssetMetadata<MediaCustomData> {
        .init(
            title: title,
            subtitle: subtitle,
            imageSource: imageSource,
            viewport: viewport,
            timeRanges: timeRanges,
            customData: customData
        )
    }
}
