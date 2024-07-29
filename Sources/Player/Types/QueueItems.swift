//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

struct QueueItems: Equatable {
    let item: PlayerItem
    let playerItem: AVPlayerItem
}

extension QueueItems {
    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge(
            item.metricEventPublisher(),
            playerItem.metricEventPublisher()
        )
        .eraseToAnyPublisher()
    }
}
