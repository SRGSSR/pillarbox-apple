//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import XCTest

/// Remark: Nimble provides support for notifications but its collector is not thread-safe and might crash during
///         collection.
public extension XCTestCase {
    /// Wait until a list of notifications has been received.
    func expectAtLeastReceived(
        notifications: [Notification],
        for names: Set<Notification.Name>,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        expectAtLeastPublished(
            values: notifications,
            from: Publishers.MergeMany(
                names.map { center.publisher(for: $0, object: object) }
            ),
            to: ==,
            timeout: timeout,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Collect notifications during some time interval and match them against an expected result.
    func expectReceived(
        notifications: [Notification],
        for names: Set<Notification.Name>,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        expectPublished(
            values: notifications,
            from: Publishers.MergeMany(
                names.map { center.publisher(for: $0, object: object) }
            ),
            to: ==,
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }

    /// Ensure no notifications are emitted during some time interval.
    func expectNoNotifications(
        for names: Set<Notification.Name>,
        object: AnyObject? = nil,
        center: NotificationCenter = .default,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        expectNothingPublished(
            from: Publishers.MergeMany(
                names.map { center.publisher(for: $0, object: object) }
            ),
            during: interval,
            file: file,
            line: line,
            while: executing
        )
    }
}
