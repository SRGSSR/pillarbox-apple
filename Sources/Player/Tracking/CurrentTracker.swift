//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class CurrentTracker {
    weak var player: Player?

    init(player: Player) {
        self.player = player
    }

    lazy var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> = {
        Empty().eraseToAnyPublisher()
    }()
}
