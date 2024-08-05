//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

struct MetricStartData: Encodable {
    let device: Device
    let os: OperatingSystem
    let screen: Screen
    let player: Player
    let media: Media
    let timeMetrics: TimeMetrics?
}

extension MetricStartData {
    struct OperatingSystem: Encodable {
        let name: String
        let version: String
    }

    struct Player: Encodable {
        let name: String
        let platform: String
        let version: String
    }

    struct Screen: Encodable {
        let width: Int
        let height: Int
    }

    struct Media: Encodable {
        let id: String?
        let metadataUrl: URL?
        let assetUrl: URL?
        let origin: String?
    }

    struct Device: Encodable {
        let id: String?
        let model: String
        let type: String
    }

    struct TimeMetrics: Encodable {
        let mediaSource: Int?
        let asset: Int?
        let total: Int

        init?(events: [MetricEvent]) {
            mediaSource = events.compactMap(Self.assetLoadingDateInterval(from:)).last
            asset = events.compactMap(Self.resourceLoadingDateInterval(from:)).first
            if let mediaSource, let asset {
                total = mediaSource + asset
            }
            else if let mediaSource {
                total = mediaSource
            }
            else if let asset {
                total = asset
            }
            else {
                return nil
            }
        }
    }
}

private extension MetricStartData.TimeMetrics {
    static func assetLoadingDateInterval(from event: MetricEvent) -> Int? {
        switch event.kind {
        case let .assetLoading(dateInterval):
            return dateInterval.duration.toMilliseconds
        default:
            return nil
        }
    }

    static func resourceLoadingDateInterval(from event: MetricEvent) -> Int? {
        switch event.kind {
        case let .resourceLoading(dateInterval):
            return dateInterval.duration.toMilliseconds
        default:
            return nil
        }
    }
}
