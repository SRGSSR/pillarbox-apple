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
    let qoeTimings: ExperienceTimings?
    let qosTimings: ServiceTimings?
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

    struct ExperienceTimings: Encodable {
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

        private static func metadata(from event: MetricEvent) -> Int? {
            switch event.kind {
            case let .metadata(experience: experience, service: _):
                return experience.duration.toMilliseconds
            default:
                return nil
            }
        }

        private static func asset(from event: MetricEvent) -> Int? {
            switch event.kind {
            case let .asset(experience: experience):
                return experience.duration.toMilliseconds
            default:
                return nil
            }
        }
    }

    struct ServiceTimings: Encodable {
        let metadata: Int?

        init?(events: [MetricEvent]) {
            metadata = events.compactMap(Self.metadata(from:)).last
        }

        private static func metadata(from event: MetricEvent) -> Int? {
            switch event.kind {
            case let .metadata(experience: _, service: service):
                return service.duration.toMilliseconds
            default:
                return nil
            }
        }
    }

    struct Screen: Encodable {
        let width: Int
        let height: Int
    }
}
