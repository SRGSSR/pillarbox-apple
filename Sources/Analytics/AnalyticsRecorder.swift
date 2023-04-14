//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public enum AnalyticsRecorder {
    static let sessionIdentifierKey = "recorder_session_id"
    private(set) static var sessionIdentifier: String?

    public static func captureComScoreEvents(perform: (AnyPublisher<ComScoreEvent, Never>) -> Void) {
        captureEvents(perform: perform) { identifier in
            ComScoreInterceptor.eventPublisher(for: identifier)
        }
    }

    public static func captureCommandersActEvents(perform: (AnyPublisher<CommandersActEvent, Never>) -> Void) {
        captureEvents(perform: perform) { identifier in
            CommandersActInterceptor.eventPublisher(for: identifier)
        }
    }

    private static func captureEvents<P>( perform: (P) -> Void, using publisher: (String) -> P) where P: Publisher, P.Failure == Never {
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
}
