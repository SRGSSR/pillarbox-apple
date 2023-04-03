//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

public struct AnalyticsTest {
    let additionalLabels: [String: String]

    init(additionalLabels: [String: String]) {
        self.additionalLabels = additionalLabels
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
        URLSession.enableInterceptor()
    }

    public func trackPageView(title: String, levels: [String] = [], labels: [String: String] = [:]) {
        let allLabels = labels.merging(additionalLabels) { _, new in new }
        Analytics.shared.trackPageView(title: title, levels: levels, labels: allLabels)
    }

    // ... and for other events
}
