//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Circumspect
import Combine
import XCTest

open class ComScoreTestCase: XCTestCase {
    private static let identifierKey = "com_score_test_id"

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
        .init(comScore: [identifierKey: id], commandersAct: [:])
    }

    private static func publisher(for id: String, key: String) -> AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] }
            .filter { $0[identifierKey] == id }
            .compactMap { $0[key] }
            .eraseToAnyPublisher()
    }
}
