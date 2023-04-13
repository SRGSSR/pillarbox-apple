//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Circumspect
import Combine
import TCCore
import XCTest

/// Parent class for Commanders Act test cases.
open class CommandersActTestCase: XCTestCase {
    private static let identifierKey = "test_id"

    private static func identifier(for function: String) -> String {
        "\(self).\(function)-\(UUID().uuidString)"
    }

    private static func additionalLabels(for id: String) -> [String: String] {
        [identifierKey: id]
    }

    private static func publisher(for id: String, key: String) -> AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: Notification.Name(rawValue: kTCNotification_HTTPRequest))
            .compactMap { Self.labels(from: $0) }
            .filter { dictionary in
                guard let identifier = dictionary[identifierKey] as? String else { return false }
                return identifier == id
            }
            .compactMap { $0[key] as? String }
            .eraseToAnyPublisher()
    }
}

public extension CommandersActTestCase {
    private static func labels(from notification: Notification) -> [String: Any]? {
        guard let body = notification.userInfo?[kTCUserInfo_POSTData] as? String,
              let data = body.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    /// Collect values emitted by Commanders Act under the specified key during some time interval and match them against
    /// an expected result.
    func expectEqual(
        values: [String],
        for key: String,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        let publisher = Self.publisher(for: id, key: key)
        expectEqualPublished(values: values, from: publisher, during: interval, file: file, line: line) {
            executing?()
        }
    }

    /// Expect Commanders Act to emit at least a list of expected values for the specified key.
    func expectAtLeastEqual(
        values: [String],
        for key: String,
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        let publisher = Self.publisher(for: id, key: key)
        expectAtLeastEqualPublished(values: values, from: publisher, timeout: timeout, file: file, line: line) {
            executing?()
        }
    }

    /// Ensure a publisher does not emit any value during some time interval.
    func expectNothingPublished(
        for key: String,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        let publisher = Self.publisher(for: id, key: key)
        expectNothingPublished(from: publisher, during: interval, file: file, line: line) {
            executing?()
        }
    }

    /// Wait until a `kTCNotification_HTTPRequest ` notification has been received as a result of executing some code.
    func wait(
        timeout: DispatchTimeInterval = .seconds(20),
        function: String = #function,
        while executing: () -> Void,
        received: @escaping ([String: Any]) -> Void
    ) {
        let id = Self.identifier(for: function)
        expectation(forNotification: Notification.Name(rawValue: kTCNotification_HTTPRequest), object: nil) { notification in
            guard let labels = Self.labels(from: notification),
                  labels[Self.identifierKey] as? String == id else {
                return false
            }
            received(labels)
            return true
        }
        executing()
        waitForExpectations(timeout: timeout.double())
    }
}
