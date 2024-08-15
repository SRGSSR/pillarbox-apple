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
        guard let item else { return .invalid }
        return item.currentTime()
    }

    func date() -> Date? {
        item?.currentDate()
    }

    func metrics() -> Metrics? {
        guard let item else { return nil }
        return MetricsState(from: item).metrics(from: .empty)
    }
}
