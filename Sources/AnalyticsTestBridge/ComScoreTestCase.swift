//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import XCTest

open class ComScoreTestCase: XCTestCase {
    private static let identifierKey = "cs_test_id"

    public func expectEqual(
        values: [String],
        for key: String,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: ((AnalyticsTest) -> Void)? = nil
    ) {
        let id = "\(Self.self).\(function)-\(UUID().uuidString)"
        let test = AnalyticsTest(additionalLabels: [Self.identifierKey: id])
        let publisher = NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] }
            .filter { $0[Self.identifierKey] == id }
            .compactMap { $0[key] }
        expectEqualPublished(values: values, from: publisher, during: interval, file: file, line: line) {
            executing?(test)
        }
    }
}
