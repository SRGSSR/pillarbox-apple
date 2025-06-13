//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import ComScore
import Foundation
import TCServerSide

/// A listener for analytics hits.
///
/// The listener must be started first and provides two methods with which comScore, respectively Commanders Act
/// hits can be captured.
///
/// Note that `AnalyticsListener` is a development-oriented tool (e.g., unit testing) which must never be used directly
/// in production code.
public enum AnalyticsListener {
    private static let sessionIdentifierKey = "listener_session_id"
    private static var sessionIdentifier: String?

    /// Starts the listener.
    ///
    /// - Parameter completion: A completion called when the listener has been started.
    public static func start(completion: @escaping () -> Void) {
        ComScoreHitInterceptor.start(completion: completion)
    }

    /// Captures comScore hits.
    ///
    /// - Parameter perform: A closure to be executed within the capture session. The session provides a publisher
    ///   which emits the associated hits.
    public static func captureComScoreHits(perform: (AnyPublisher<ComScoreHit, Never>) -> Void) {
        captureHits(perform: perform) { identifier in
            ComScoreHitInterceptor.publisher(for: identifier)
        }
    }

    /// Captures Commanders Act hits.
    ///
    /// - Parameter perform: A closure to be executed within the capture session. The session provides a publisher
    ///   which emits the associated hits.
    public static func captureCommandersActHits(perform: (AnyPublisher<CommandersActHit, Never>) -> Void) {
        captureHits(perform: perform) { identifier in
            CommandersActHitInterceptor.publisher(for: identifier)
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

    static func capture(_ labels: inout [String: String]) {
        guard let sessionIdentifier else { return }
        labels[sessionIdentifierKey] = sessionIdentifier
    }

    static func capture(_ configuration: SCORStreamingConfiguration) {
        guard let sessionIdentifier else { return }
        configuration.setLabelWithName(sessionIdentifierKey, value: sessionIdentifier)
    }

    static func capture(_ event: TCEvent) {
        guard let sessionIdentifier else { return }
        event.addNonBlankAdditionalProperty(sessionIdentifierKey, withStringValue: sessionIdentifier)
    }
}
