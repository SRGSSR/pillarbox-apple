//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol AnalyticsService {
    func start(with configuration: Analytics.Configuration)
    func trackPageView(title: String, levels: [String], labels: Analytics.Labels?)
}
