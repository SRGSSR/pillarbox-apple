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
    /// The event.
    public enum Event: Equatable { // swiftlint:disable:this test_case_accessibility
        /// The field related to the event.
        public enum Field: Equatable {
            case ns_st_id(String)
            case ns_st_ldw(Int)
            case ns_st_po(Int)
        }

        case play(fields: [Field])
        case pause(fields: [Field])
        case end(fields: [Field])

        init?(from dictionary: [String: String]) {
            guard let event = dictionary["ns_st_ev"] else { return nil }
            switch event {
            case "play":
                self = .play(fields: [
                    .ns_st_id(dictionary["ns_st_id"]!),
                    .ns_st_ldw(Int(dictionary["ns_st_ldw"]!)!),
                    .ns_st_po(Int(dictionary["ns_st_po"]!)!)
                ])
            case "pause":
                self = .pause(fields: [
                    .ns_st_id(dictionary["ns_st_id"]!),
                    .ns_st_ldw(Int(dictionary["ns_st_ldw"]!)!),
                    .ns_st_po(Int(dictionary["ns_st_po"]!)!)
                ])
            case "end":
                self = .end(fields: [
                    .ns_st_id(dictionary["ns_st_id"]!),
                    .ns_st_ldw(Int(dictionary["ns_st_ldw"]!)!),
                    .ns_st_po(Int(dictionary["ns_st_po"]!)!)
                ])
            default:
                return nil
            }
        }
    }

    private static let identifierKey = "com_score_test_id"

    private static func identifier(for function: String) -> String {
        "\(self).\(function)-\(UUID().uuidString)"
    }

    private static func additionalLabels(for id: String) -> [String: String] {
        [identifierKey: id]
    }

    private static func eventPublisher(for id: String) -> AnyPublisher<Event, Never> {
        NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] }
            .filter { $0[identifierKey] == id }
            .compactMap { .init(from: $0) }
            .eraseToAnyPublisher()
    }
}

public extension ComScoreTestCase {
    /// Collect events emitted by comScore under the specified key during some time interval and match them against
    /// an expected result.
    func expectEvents(
        _ events: [Event],
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: ((AnalyticsTest) -> Void)? = nil
    ) {
        let id = Self.identifier(for: function)
        let publisher = Self.eventPublisher(for: id)
        expectEqualPublished(values: [], from: publisher, during: interval, file: file, line: line) {
            executing?(AnalyticsTest(additionalLabels: Self.additionalLabels(for: id)))
        }
    }

    /// Collect events emitted by comScore under the specified key during some time interval and match them against
    /// an expected result.
    func expectAtLeastEvents(
        _ events: [Event],
        timeout: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: ((AnalyticsTest) -> Void)? = nil
    ) {
    }
}

public extension ComScoreTestCase {
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
