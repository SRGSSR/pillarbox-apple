//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Circumspect
import XCTest

class TestCase: XCTestCase {
    override class func setUp() {
        super.setUp()
        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))
    }
}

struct AnalyticsSUT {
    let id: String

    init(id: String) {
        self.id = id
        URLSession.enableInterceptor()
    }

    public func trackPageView(title: String, levels: [String] = [], labels: [String: String] = [:]) {
        var allLabels = labels
        allLabels["pillarbox_test_id"] = id
        Analytics.shared.trackPageView(title: title, levels: levels, labels: allLabels)
    }

    // ... and for other events
}

extension XCTestCase {
    func expect(
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
