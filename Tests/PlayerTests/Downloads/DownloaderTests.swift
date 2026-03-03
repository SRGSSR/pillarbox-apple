//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams
import XCTest

final class DownloaderTests: TestCase {
    func testEmpty() {
        expect(Downloader().downloads).to(beEmpty())
    }

    func testAdd() {
        let downloader = Downloader()
        let download = downloader.add(url: Stream.shortOnDemand.url)
        expect(downloader.downloads).to(equal([download]))
    }

    func testRemove() {
        let downloader = Downloader()
        let download = downloader.add(url: Stream.shortOnDemand.url)
        downloader.remove(download)
        expect(downloader.downloads).to(beEmpty())
    }
}
