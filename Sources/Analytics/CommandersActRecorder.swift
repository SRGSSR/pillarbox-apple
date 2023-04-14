//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import TCServerSide_noIDFA

public enum CommandersActRecorder {
    static let sessionIdentifierKey = "recorder_session_id"
    private(set) static var sessionIdentifier: String?

    /// Execute the provided closure in a test context identified with the provided identifier.
    public static func captureEvents(perform: (AnyPublisher<CommandersActEvent, Never>) -> Void) {
        assert(sessionIdentifier == nil, "Multiple captures are not supported")

        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))

        let identifier = UUID().uuidString
        sessionIdentifier = identifier
        defer {
            sessionIdentifier = nil
        }

        let publisher = eventPublisher(for: identifier)
        perform(publisher)
    }

    private static func eventPublisher(for identifier: String) -> AnyPublisher<CommandersActEvent, Never> {
        NotificationCenter.default.publisher(for: .init(rawValue: kTCNotification_HTTPRequest))
            .compactMap { labels(from: $0) }
            .filter {
                $0.recorder_session_id == identifier
            }
            .compactMap { .init(from: $0) }
            .eraseToAnyPublisher()
    }

    private static func labels(from notification: Notification) -> CommandersActLabels? {
        guard let body = notification.userInfo?[kTCUserInfo_POSTData] as? String,
              let data = body.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(CommandersActLabels.self, from: data)
    }
}
