//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

public struct AnalyticsSUT {
    public let id: String

    init(id: String) {
        self.id = id
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
        URLSession.enableInterceptor()
    }

    public func trackPageView(title: String, levels: [String] = [], labels: [String: String] = [:]) {
        var allLabels = labels
        allLabels["pillarbox_test_id"] = id
        Analytics.shared.trackPageView(title: title, levels: levels, labels: allLabels)
    }

    // ... and for other events
}
