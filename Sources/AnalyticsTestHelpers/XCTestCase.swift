//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import XCTest

public extension XCTestCase {
    func expectEqual(
        values: [String],
        for key: String,
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        function: String = #function,
        while executing: ((AnalyticsSUT) -> Void)? = nil
    ) {
        let id = "\(Self.self).\(function)-\(UUID().uuidString)"
        let sut = AnalyticsSUT(id: id)
        let publisher = NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .print()
            .compactMap {
                $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String]
            }
            .filter {
                $0["pillarbox_test_id"] == id
            }
            .compactMap { $0[key] }
        expectEqualPublished(values: values, from: publisher, during: interval, file: file, line: line) {
            executing?(sut)
        }
    }
}
