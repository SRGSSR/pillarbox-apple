//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Player

public extension ComScoreTracker {
    static func adapter(test: AnalyticsTest) -> TrackerAdapter<Never> {
        TrackerAdapter(trackerType: Self.self, configuration: .init(labels: test.additionalLabels), mapper: nil)
    }
}
