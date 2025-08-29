//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

import Nimble
import XCTest

final class TrackingSessionTests: XCTestCase {
    func testEmpty() {
        let session = TrackingSession()
        expect(session.id).to(beNil())
        expect(session.isStarted).to(beFalse())
    }

    func testStart() {
        let session = TrackingSession()
        session.start()
        expect(session.id).notTo(beNil())
        expect(session.isStarted).to(beTrue())
    }

    func testStop() {
        let session = TrackingSession()
        session.start()
        session.stop()
        expect(session.id).notTo(beNil())
        expect(session.isStarted).to(beFalse())
    }

    func testReset() {
        let session = TrackingSession()
        session.start()
        session.reset()
        expect(session.id).to(beNil())
        expect(session.isStarted).to(beFalse())
    }
}
