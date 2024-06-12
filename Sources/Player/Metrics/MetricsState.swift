//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricsState {
    let log: AccessLog
    let 

    func update(with log: AccessLog) -> MetricsState {
        .init(log: .init(events: [], after: date))
    }
}
