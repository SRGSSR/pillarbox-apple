//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import TCServerSide_noIDFA

/// Provide a context in which analytics events can be listen. Should never be used in production, only for
/// development purposes (e.g. unit tests).
public enum AnalyticsListener {
    private static let sessionIdentifierKey = "listener_session_id"
    private static var sessionIdentifier: String?

    /// Capture comScore events.
    /// - Parameter perform: A closure to be executed. Receives a publisher which emits the events received during
    ///   the capture.
    public static func captureComScoreEvents(perform: (AnyPublisher<ComScoreEvent, Never>) -> Void) {
        captureEvents(perform: perform) { identifier in
            ComScoreInterceptor.eventPublisher(for: identifier)
        }
    }

    /// Capture Commanders Act events.
    /// - Parameter perform: A closure to be executed. Receives a publisher which emits the events received during
    ///   the capture.
    public static func captureCommandersActEvents(perform: (AnyPublisher<CommandersActEvent, Never>) -> Void) {
        captureEvents(perform: perform) { identifier in
            CommandersActInterceptor.eventPublisher(for: identifier)
        }
    }

    private static func captureEvents<P>(perform: (P) -> Void, using publisher: (String) -> P) where P: Publisher, P.Failure == Never {
        assert(sessionIdentifier == nil, "Multiple captures are not supported")

        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))

        let identifier = UUID().uuidString
        ComScoreInterceptor.toggle()
        sessionIdentifier = identifier
        defer {
            ComScoreInterceptor.toggle()
            sessionIdentifier = nil
        }

        perform(publisher(identifier))
    }

    static func capture(_ labels: inout [String: String]) {
        guard let sessionIdentifier else { return }
        labels[sessionIdentifierKey] = sessionIdentifier
    }

    static func capture(_ event: TCEvent) {
        guard let sessionIdentifier else { return }
        event.addNonBlankAdditionalProperty(sessionIdentifierKey, withStringValue: sessionIdentifier)
    }
}
