//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum MetricHitListener {
    private static var sessionIdentifier: String?

    static func captureMetricHits(perform: (AnyPublisher<Encodable, Never>) -> Void) {
        captureHits(perform: perform) { identifier in
            MetricHitInterceptor.publisher(for: identifier)
        }
    }

    private static func captureHits<P>(perform: (P) -> Void, using publisher: (String) -> P) where P: Publisher, P.Failure == Never {
        assert(sessionIdentifier == nil, "Multiple captures are not supported")

        let identifier = UUID().uuidString
        sessionIdentifier = identifier
        defer {
            sessionIdentifier = nil
        }

        perform(publisher(identifier))
    }

    static func capture(_ payload: Encodable) {
        guard let sessionIdentifier else { return }
        NotificationCenter.default.post(name: .didSendMetricRequest, object: self, userInfo: [
            MetricRequestInfoKey.identifier: sessionIdentifier,
            MetricRequestInfoKey.payload: payload
        ])
    }
}
