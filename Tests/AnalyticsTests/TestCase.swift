//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import XCTest

class TestCase: XCTestCase {
    private var testId = UUID().uuidString

    override class func setUp() {
        super.setUp()
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
}
