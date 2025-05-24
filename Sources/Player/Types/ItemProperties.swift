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

    // TODO: Should document performance considerations. Idea:
    //   - Make the call async (usual closure). Capture the time() before, then use the time() after and the date() to return
    //     the date() at the time of the call. This way the value is correct, corresponds to the calling site but is delivered
    //     a bit later (this handles seek origin position correctly).
    func metrics() -> Metrics? {
        guard let item, item.isLoaded, let state = MetricsState.state(from: item) else { return nil }
        return state.metrics(from: .empty)
    }
}
