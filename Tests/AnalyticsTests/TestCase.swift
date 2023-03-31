//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Circumspect
import XCTest

class TestCase: XCTestCase {
    private var testId = UUID().uuidString

    override class func setUp() {
        super.setUp()
        URLSession.enableInterceptor()
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
    }

    override func setUp() {
        super.setUp()
        testId = UUID().uuidString
    }
}

extension TestCase {
    public func trackTestPageView(title: String, levels: [String] = [], labels: [String: String] = [:]) {
        var allLabels = labels
        allLabels["pillarbox_test_id"] = testId
        Analytics.shared.trackPageView(title: title, levels: levels, labels: allLabels)
    }

    public func expect(
        events: [String],
        during interval: DispatchTimeInterval = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        while executing: (() -> Void)? = nil
    ) {
        let publisher = NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .print()
            .compactMap {
                $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String]
            }
            .filter {
                $0["pillarbox_test_id"] == self.testId
            }
            .compactMap { $0["c2"] }
        expectEqualPublished(values: events, from: publisher, during: interval, file: file, line: line, while: executing)
    }
}
