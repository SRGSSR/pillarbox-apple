//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics
import Foundation

/// Analytics test context.
public struct AnalyticsTest {
    let additionalLabels: [String: String]

    init(additionalLabels: [String: String]) {
        self.additionalLabels = additionalLabels
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
        URLSession.enableInterceptor()
    }

    /// Record a page view event within the test context.
    /// - Parameters:
    ///   - title: The page title.
    ///   - levels: The page levels.
    ///   - labels: Labels associated with the event.
    public func trackPageView(title: String, levels: [String] = []) {
        Analytics.shared.trackPageView(title: title, levels: levels, labels: .init(comScore: additionalLabels, commandersAct: additionalLabels))
    }
}
