//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AnalyticsTestHelpers
import CoreBusiness
import Player

public extension ComScoreTracker {
    static func adapter(sut: AnalyticsSUT) -> TrackerAdapter<Never> {
        TrackerAdapter(trackerType: Self.self, configuration: .init(labels: sut.labels), mapper: nil)
    }
}
