//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import ObjectiveC

final class CommandersActStreamingAnalyticsTests: CommandersActTestCase {
    func testDeallocation() {
        var object: CommandersActStreamingAnalytics? = CommandersActStreamingAnalytics(streamType: .onDemand) { .empty }
        weak var weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())
    }
}
