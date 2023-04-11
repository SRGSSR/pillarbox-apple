//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Circumspect
import Combine
import XCTest

/// Parent class for comScore test cases.
open class ComScoreTestCase: XCTestCase {
    private static let identifierKey = "com_score_test_id"

    private static func identifier(for function: String) -> String {
        "\(self).\(function)-\(UUID().uuidString)"
    }

    private static func additionalLabels(for id: String) -> [String: String] {
        [identifierKey: id]
    }

    private static func publisher(for id: String, key: String) -> AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] }
            .filter { $0[identifierKey] == id }
            .compactMap { $0[key] }
            .eraseToAnyPublisher()
    }
}

public extension ComScoreTestCase {
    /// Collect values emitted by comScore under the specified key during some time interval and match them against
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

    /// Expect comScore to emit at least a list of expected values for the specified key.
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

    /// Wait until a `didReceiveComScoreRequest` notification has been received as a result of executing some code.
    func wait(
        timeout: DispatchTimeInterval = .seconds(20),
        function: String = #function,
        while executing: (AnalyticsTest) -> Void,
        received: @escaping ([String: String]) -> Void
    ) {
        let id = Self.identifier(for: function)
        expectation(forNotification: .didReceiveComScoreRequest, object: nil) { notification in
            guard let labels = notification.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String],
                       labels[Self.identifierKey] == id else {
                return false
            }
            received(labels)
            return true
        }
        executing(AnalyticsTest(additionalLabels: Self.additionalLabels(for: id)))
        waitForExpectations(timeout: timeout.double())
    }
}
