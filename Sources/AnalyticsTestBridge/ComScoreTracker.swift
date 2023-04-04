//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreBusiness
import Player

public extension ComScoreTracker {
    /// Create a tracker adapter associating data with the provided test context.
    /// - Parameter test: The test context.
    /// - Returns: The tracker adapter.
    static func adapter(test: AnalyticsTest) -> TrackerAdapter<Never> {
        TrackerAdapter(trackerType: Self.self, configuration: .init(labels: test.additionalLabels), mapper: nil)
    }
}
