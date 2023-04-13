//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics
import Circumspect
import Combine
import XCTest

/// Parent class for comScore test cases.
open class ComScoreTestCase: XCTestCase {
    private static func identifier(for function: String) -> String {
        "\(self).\(function)-\(UUID().uuidString)"
    }

    private static func additionalLabels(for id: String) -> [String: String] {
        [Analytics.testIdentifierKey: id]
    }

    private static func eventPublisher(for id: String) -> AnyPublisher<ComScoreEvent, Never> {
        NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] }
            .filter { $0[Analytics.testIdentifierKey] == id }
            .compactMap { .init(from: $0) }
            .eraseToAnyPublisher()
    }
}

public extension ComScoreTestCase {
    /// Collect events emitted by comScore under the specified key during some time interval and match them against
    /// an expected result.
    func expectEvents(
        _ expectations: [ComScoreEventExpectation],
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        executeTests(withId: id) {
            expectPublished(
                values: expectations,
                from: Self.eventPublisher(for: id),
                to: ComScoreEventExpectation.match(event:with:),
                during: interval,
                file: file,
                line: line,
                while: executing
            )
        }
    }

    /// Collect events emitted by comScore under the specified key during some time interval and match them against
    /// an expected result.
    func expectAtLeastEvents(
        _ expectations: [ComScoreEventExpectation],
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: (() -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        executeTests(withId: id) {
            expectAtLeastPublished(
                values: expectations,
                from: Self.eventPublisher(for: id),
                to: ComScoreEventExpectation.match(event:with:),
                timeout: timeout,
                file: file,
                line: line,
                while: executing
            )
        }
    }
}

public extension ComScoreTestCase {
    /// Wait until a `didReceiveComScoreRequest` notification has been received as a result of executing some code.
    func wait(
        timeout: DispatchTimeInterval = .seconds(20),
        function: String = #function,
        while executing: () -> Void,
        received: @escaping ([String: String]) -> Void
    ) {
        let id = Self.identifier(for: function)
        executeTests(withId: id) {
            expectation(forNotification: .didReceiveComScoreRequest, object: nil) { notification in
                guard let labels = notification.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String],
                      labels[Analytics.testIdentifierKey] == id else {
                    return false
                }
                received(labels)
                return true
            }
            executing()
            waitForExpectations(timeout: timeout.double())
        }
    }

    private func executeTests(withId id: String, perform: () -> Void) {
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
        URLSession.enableInterceptor()
        Analytics.shared.executeTests(withId: id, perform: perform)
    }
}
