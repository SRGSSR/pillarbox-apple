//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import TCCore

/// A tool that intercepts Commanders Act requests and turns them into a hit stream.
enum CommandersActHitInterceptor {
    static func publisher(for identifier: String) -> AnyPublisher<CommandersActHit, Never> {
        NotificationCenter.default.publisher(for: .init(rawValue: kTCNotification_HTTPRequest))
            .compactMap { labels(from: $0) }
            .filter { $0.listener_session_id == identifier }
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
