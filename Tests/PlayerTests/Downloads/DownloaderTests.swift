//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import XCTest

final class DownloaderTests: TestCase {
    func testEmpty() {
        expect(Downloader().downloads).to(beEmpty())
    }
}
