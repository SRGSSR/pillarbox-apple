//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

public struct AnalyticsSUT {
    public let labels: [String: String]

    init(id: String) {
        self.labels = ["pillarbox_test_id": id]
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
        URLSession.enableInterceptor()
    }

    public func trackPageView(title: String, levels: [String] = [], labels: [String: String] = [:]) {
        let allLabels = labels.merging(self.labels) { _, new in new }
        Analytics.shared.trackPageView(title: title, levels: levels, labels: allLabels)
    }

    // ... and for other events
}
