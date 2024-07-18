//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore

extension Player {
    func currentTrackerPublisher() -> AnyPublisher<CurrentTracker?, Never> {
        Publishers.CombineLatest(queuePublisher.slice(at: \.item), $isTrackingEnabled)
            .map { (item: $0, isTrackingEnabled: $1) }
            .scan(nil) { [weak self] tracker, next in
                if let self, !next.isTrackingEnabled {
                    tracker?.release(player: self)
                }
                if let self, next.isTrackingEnabled, let item = next.item {
                    guard tracker?.item !== item else { return tracker }
                    tracker?.release(player: self)
                    return CurrentTracker(item: item, player: self)
                }
                else {
                    if let self {
                        tracker?.release(player: self)
                    }
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}
