//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum MetricRequestInfoKey: String {
    case identifier = "MetricRequestInfoKey_identifier"
    case payload = "MetricRequestInfoKey_payload"
}

extension Notification.Name {
    static let didSendMetricRequest = Notification.Name(rawValue: "PillarboxMonitoring_didSendMetricRequest")
}
