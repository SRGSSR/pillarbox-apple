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
    let qoeMetrics: QualityOfExperienceMetrics?
}

extension MetricStartData {
    struct Device: Encodable {
        let id: String?
        let model: String
        let type: String
    }

    struct Media: Encodable {
        let assetUrl: URL?
        let id: String?
        let metadataUrl: URL?
        let origin: String?
    }

    struct OperatingSystem: Encodable {
        let name: String
        let version: String
    }

    struct Player: Encodable {
        let name: String
        let platform: String
        let version: String
    }

    struct QualityOfExperienceMetrics: Encodable {
        let metadata: Int?
        let asset: Int?
        let total: Int

        init?(events: [MetricEvent]) {
            metadata = events.compactMap(Self.metadata(from:)).last
            asset = events.compactMap(Self.asset(from:)).first
            if let metadata, let asset {
                total = metadata + asset
            }
            else if let metadata {
                total = metadata
            }
            else if let asset {
                total = asset
            }
            else {
                return nil
            }
        }
    }

    struct Screen: Encodable {
        let width: Int
        let height: Int
    }
}

private extension MetricStartData.QualityOfExperienceMetrics {
    static func metadata(from event: MetricEvent) -> Int? {
        switch event.kind {
        case let .metadata(qoe: qoe, qos: _):
            return qoe.duration.toMilliseconds
        default:
            return nil
        }
    }

    static func asset(from event: MetricEvent) -> Int? {
        switch event.kind {
        case let .asset(qoe: qoe):
            return qoe.duration.toMilliseconds
        default:
            return nil
        }
    }
}
