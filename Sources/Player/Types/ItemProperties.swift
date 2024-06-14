//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

struct ItemProperties: Equatable {
    static let empty = Self(
        item: nil,
        status: .unknown,
        duration: .invalid,
        minimumTimeOffsetFromLive: .invalid,
        presentationSize: nil,
        metricsState: .empty
    )

    let item: AVPlayerItem?
    let status: ItemStatus

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?
    let metricsState: MetricsState

    func metrics() -> Metrics? {
        guard let updatedState = metricsState.updated(with: item?.accessLog()) else { return nil }
        return updatedState.metrics(from: metricsState)
    }
}
