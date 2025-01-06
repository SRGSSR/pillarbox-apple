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
        // Check cached duration validity first. This avoids potentially costly date retrieval when playing some
        // content (e.g., MP3).
        duration.isValid ? item?.currentDate() : nil
    }

    func metrics() -> Metrics? {
        guard let item, item.isLoaded, let state = MetricsState(from: item) else { return nil }
        return state.metrics(from: .empty)
    }
}
