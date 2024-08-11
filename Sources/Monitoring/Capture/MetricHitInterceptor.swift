//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

/// A tool that intercepts metric requests and turns them into a hit stream.
enum MetricHitInterceptor {
    static func publisher(for identifier: String) -> AnyPublisher<Encodable, Never> {
        NotificationCenter.default.publisher(for: .didSendMetricRequest)
            .compactMap { payload(from: $0, for: identifier) }
            .eraseToAnyPublisher()
    }

    private static func payload(from notification: Notification, for identifier: String) -> Encodable? {
        guard let userInfo = notification.userInfo,
              let requestIdentifier = userInfo[MetricRequestInfoKey.identifier] as? String, requestIdentifier == identifier else {
            return nil
        }
        return userInfo[MetricRequestInfoKey.payload] as? Encodable
    }
}
