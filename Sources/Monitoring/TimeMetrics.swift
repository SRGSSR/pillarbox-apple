//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

struct TimeMetrics: Encodable {
    let mediaSource: UInt?
    let asset: UInt?
    let total: UInt

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

private extension TimeMetrics {
    static func assetLoadingDateInterval(from event: MetricEvent) -> UInt? {
        switch event.kind {
        case let .assetLoading(dateInterval):
            return UInt(round(dateInterval.duration * 1000))
        default:
            return nil
        }
    }

    static func resourceLoadingDateInterval(from event: MetricEvent) -> UInt? {
        switch event.kind {
        case let .resourceLoading(dateInterval):
            return UInt(round(dateInterval.duration * 1000))
        default:
            return nil
        }
    }
}
