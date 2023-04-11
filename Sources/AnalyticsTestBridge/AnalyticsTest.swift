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
    public func sendPageView(title: String, levels: [String] = []) {
        Analytics.shared.sendPageView(title: title, levels: levels, labels: .init(comScore: additionalLabels, commandersAct: additionalLabels))
    }

    /// Record an event.
    /// - Parameters:
    ///   - name: The event name.
    ///   - type: The event type.
    ///   - value: The event value.
    ///   - source: The event source.
    ///   - extra1: The event extra1.
    ///   - extra2: The event extra2.
    ///   - extra3: The event extra3.
    ///   - extra4: The event extra4.
    ///   - extra5: The event extra5.
    public func sendEvent(
        name: String = "",
        type: String = "",
        value: String = "",
        source: String = "",
        extra1: String = "",
        extra2: String = "",
        extra3: String = "",
        extra4: String = "",
        extra5: String = ""
    ) {
        Analytics.shared.sendEvent(
            name: name,
            type: type,
            value: value,
            source: source,
            extra1: extra1,
            extra2: extra2,
            extra3: extra3,
            extra4: extra4,
            extra5: extra5,
            labels: .init(comScore: additionalLabels, commandersAct: additionalLabels)
        )
    }
}
