//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol AnalyticsService {
    func start(with configuration: Analytics.Configuration)
    func trackPageView(title: String, levels: [String], labels: Labels?)
    // swiftlint:disable:next function_parameter_count
    func sendEvent(
        name: String,
        type: String,
        value: String,
        source: String,
        extra1: String,
        extra2: String,
        extra3: String,
        extra4: String,
        extra5: String,
        labels: Labels?
    )
}
