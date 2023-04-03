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

open class CommandersActTestCase: XCTestCase {
    private static let identifierKey = "commanders_act_test_id"

    public func expectEqual(
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

    public func expectAtLeastEqual(
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
            .decode(type: [String: String].self, decoder: JSONDecoder())
            .replaceError(with: [:])
            .filter { $0[identifierKey] == id }
            .compactMap { $0[key] }
            .eraseToAnyPublisher()
    }
}
