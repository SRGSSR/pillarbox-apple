//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import Nimble

@available(tvOS, unavailable)
final class DownloadSizeTests: TestCase {
    func testValid() throws {
        let size = try unwrap(DownloadSize(completed: 50, total: 100))
        expect(size.completed).to(equal(50))
        expect(size.total).to(equal(100))
    }

    func testInvalid() {
        expect(DownloadSize(completed: 50, total: 0)).to(beNil())
    }

    func testTotal() throws {
        let size = try unwrap(DownloadSize(total: 100))
        expect(size.completed).to(equal(100))
        expect(size.total).to(equal(100))
    }

    func testCompletedNeverLagerThanTotal() throws {
        let size = try unwrap(DownloadSize(completed: 150, total: 100))
        expect(size.completed).to(equal(100))
        expect(size.total).to(equal(100))
    }

    func testCompletedNeverNegative() throws {
        let size = try unwrap(DownloadSize(completed: -10, total: 100))
        expect(size.completed).to(equal(0))
        expect(size.total).to(equal(100))
    }
}
