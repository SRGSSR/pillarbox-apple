//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol AnalyticsService {
    func start(with configuration: Analytics.Configuration)
    func sendPageView(title: String, levels: [String])
    func sendEvent(_ event: Event)
}
