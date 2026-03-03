//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams
import XCTest

final class DownloadTests: TestCase {
    func testCreation() {
        let download = Download(url: Stream.shortOnDemand.url)
        expect(download.state).to(equal(.running))
    }
}
