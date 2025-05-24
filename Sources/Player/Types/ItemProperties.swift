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
        isStalled: false
    )

    let item: AVPlayerItem?
    let status: ItemStatus

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?

    let isStalled: Bool
}

extension ItemProperties {
    func time() -> CMTime {
        item?.currentTime() ?? .invalid
    }

    // TODO: Should document performance considerations
    func date() -> Date? {
        item?.currentDate()
    }

    // TODO: Should document performance considerations
    func metrics() -> Metrics? {
        guard let item, item.isLoaded, let state = MetricsState.state(from: item) else { return nil }
        return state.metrics(from: .empty)
    }
}
