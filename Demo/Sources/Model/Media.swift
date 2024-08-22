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
        case monoscopicUrl(URL)
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
    let startTime: CMTime
    let timeRanges: [TimeRange]

    init(
        title: String,
        subtitle: String? = nil,
        imageUrl: URL? = nil,
        image: UIImage? = nil,
        type: `Type`,
        startTime: CMTime = .zero,
        timeRanges: [TimeRange] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.image = image
        self.type = type
        self.startTime = startTime
        self.timeRanges = timeRanges
    }

    func item() -> PlayerItem {
        switch type {
        case let .url(url), let .monoscopicUrl(url):
            return .simple(
                url: url,
                metadata: self,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.title)
                    }
                ],
                source: self,
                configuration: .init(position: at(startTime))
            )
        case let .tokenProtectedUrl(url):
            return .tokenProtected(
                url: url,
                metadata: self,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.title)
                    }
                ],
                source: self,
                configuration: .init(position: at(startTime))
            )
        case let .encryptedUrl(url, certificateUrl: certificateUrl):
            return .encrypted(
                url: url,
                certificateUrl: certificateUrl,
                metadata: self,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.title)
                    }
                ],
                source: self,
                configuration: .init(position: at(startTime))
            )
        case let .unbufferedUrl(url):
            let configuration = PlayerItemConfiguration(
                position: at(startTime),
                automaticallyPreservesTimeOffsetFromLive: true,
                preferredForwardBufferDuration: 1
            )
            return .simple(
                url: url,
                metadata: self,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.title)
                    }
                ],
                source: self,
                configuration: .init(position: at(startTime))
            )
        case let .urn(urn, serverSetting: serverSetting):
            return .urn(
                urn,
                server: serverSetting.server,
                trackerAdapters: [
                    DemoTracker.adapter { metadata in
                        DemoTracker.Metadata(title: metadata.mediaComposition.mainChapter.title)
                    }
                ],
                source: self,
                configuration: .init(position: at(startTime))
            )
        }
    }

    func playerItem() -> AVPlayerItem? {
        switch type {
        case let .url(url), let .monoscopicUrl(url):
            return AVPlayerItem(url: url)
        case let .unbufferedUrl(url):
            let item = AVPlayerItem(url: url)
            item.automaticallyPreservesTimeOffsetFromLive = true
            item.preferredForwardBufferDuration = 1
            return item
        default:
            return nil
        }
    }
}

extension Media: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(title: title, subtitle: subtitle, imageSource: imageSource, viewport: viewport, timeRanges: timeRanges)
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

    private var viewport: Viewport {
        switch type {
        case .monoscopicUrl:
            return .monoscopic
        default:
            return .standard
        }
    }
}
