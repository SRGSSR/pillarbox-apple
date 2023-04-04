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
    private static let identifierKey = "commanders_act_test_id"

    private static func identifier(for function: String) -> String {
        "\(self).\(function)-\(UUID().uuidString)"
    }

    private static func additionalLabels(for id: String) -> Analytics.Labels {
        .init(comScore: [:], commandersAct: [identifierKey: id])
    }

    private static func publisher(for id: String, key: String) -> AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: Notification.Name(rawValue: kTCNotification_HTTPRequest))
            .compactMap { $0.userInfo?[kTCUserInfo_POSTData] as? String }
            .compactMap { $0.data(using: .utf8) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
            .filter { dictionary in
                guard let identifier = dictionary[identifierKey] as? String else { return false }
                return identifier == id
            }
            .compactMap { $0[key] as? String }
            .eraseToAnyPublisher()
    }
}

public extension CommandersActTestCase {
    /// Collect values emitted by Commanders Act under the specified key during some time interval and match them against
    /// an expected result.
    func expectEqual(
        values: [String],
        for key: String,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: ((AnalyticsTest) -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        let publisher = Self.publisher(for: id, key: key)
        expectEqualPublished(values: values, from: publisher, during: interval, file: file, line: line) {
            executing?(AnalyticsTest(additionalLabels: Self.additionalLabels(for: id)))
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
        while executing: ((AnalyticsTest) -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        let publisher = Self.publisher(for: id, key: key)
        expectAtLeastEqualPublished(values: values, from: publisher, timeout: timeout, file: file, line: line) {
            executing?(AnalyticsTest(additionalLabels: Self.additionalLabels(for: id)))
        }
    }
}
