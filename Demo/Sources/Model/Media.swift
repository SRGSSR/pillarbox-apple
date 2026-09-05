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
        case url(URL, protection: Protection)
        case urn(String, serverSetting: ServerSetting)
        case item(PlayerItem)

        static func url(_ url: URL) -> Self {
            .url(url, protection: .none)
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
        case let .url(url, protection: protection):
            return .custom(
                assetProviderType: MediaAssetProvider.self,
                url: url,
                metadata: metadata(protection: protection),
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
        case let .item(item):
            return item
        }
    }

    func playerItem() -> AVPlayerItem? {
        switch kind {
        case let .url(url, protection: _):
            return AVPlayerItem(url: url)
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

    func metadata(protection: Protection) -> AssetMetadata<Protection> {
        .init(title: title, subtitle: subtitle, imageSource: imageSource, viewport: viewport, timeRanges: timeRanges, customData: protection)
    }
}
