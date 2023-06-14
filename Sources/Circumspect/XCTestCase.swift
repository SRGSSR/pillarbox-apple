//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import XCTest

public extension XCTestCase {
    /// Waits for a specified time interval.
    /// 
    /// - Parameter interval: The wait interval.
    func wait(for interval: DispatchTimeInterval) {
        XCTWaiter().wait(for: [XCTestExpectation()], timeout: interval.double())
    }
}
