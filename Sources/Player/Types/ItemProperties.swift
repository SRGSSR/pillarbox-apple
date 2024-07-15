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
        metricsState: .empty,
        isStalled: false
    )

    let item: AVPlayerItem?
    let status: ItemStatus

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?
    let metricsState: MetricsState

    let isStalled: Bool

    func metrics() -> Metrics? {
        guard let item else { return nil }
        let updatedState = metricsState.updated(with: item.accessLog(), at: item.currentTime())
        return updatedState.metrics(from: metricsState)
    }
}
