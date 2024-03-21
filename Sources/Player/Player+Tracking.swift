//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore

extension Player {
    func trackerPublisher() -> AnyPublisher<Tracker?, Never> {
        Publishers.CombineLatest(queuePublisher.slice(at: \.item), $isTrackingEnabled)
            .map { (item: $0, isTrackingEnabled: $1) }
            .scan(nil) { [weak self] tracker, update in
                if update.isTrackingEnabled, let item = update.item {
                    guard tracker?.item != item else { return tracker }
                    return Tracker(item: item, player: self)
                }
                else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}
