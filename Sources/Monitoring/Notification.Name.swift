//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum MetricRequestInfoKey: String {
    case identifier = "MetricRequestIdentifier"
    case payload = "MetricRequestIdentifierPayload"
}

extension Notification.Name {
    static let didSendMetricRequest = Notification.Name(rawValue: "MetricsTrackerDidSendMetricRequestNotification")
}
