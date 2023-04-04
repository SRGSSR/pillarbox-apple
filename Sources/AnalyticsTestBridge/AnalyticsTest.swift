//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

/// Analytics test context.
public struct AnalyticsTest {
    let additionalLabels: Analytics.Labels

    init(additionalLabels: Analytics.Labels) {
        self.additionalLabels = additionalLabels
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
        URLSession.enableInterceptor()
    }

    /// Record a page view event within the test context.
    /// - Parameters:
    ///   - title: The page title.
    ///   - levels: The page levels.
    ///   - labels: Labels associated with the event.
    public func trackPageView(title: String, levels: [String] = [], labels: Analytics.Labels? = nil) {
        let allLabels = labels?.merging(additionalLabels) ?? additionalLabels
        Analytics.shared.trackPageView(title: title, levels: levels, labels: allLabels)
    }
}
