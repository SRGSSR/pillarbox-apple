//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum MetricsRequest: String {
    case id = "metrics_request_id"
    case payload = "metrics_request_payload"
}

extension Notification.Name {
    static let didSendMetricsRequest = Notification.Name(rawValue: "MetricsTrackerDidSendMetricsRequestNotification")
}
