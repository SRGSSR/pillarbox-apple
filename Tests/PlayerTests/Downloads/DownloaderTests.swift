//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
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
        let download = downloader.add(title: "Title", url: Stream.shortOnDemand.url)
        expect(downloader.downloads).to(equal([download]))
    }

    func testRemove() {
        let downloader = Downloader()
        let download = downloader.add(title: "Title", url: Stream.shortOnDemand.url)
        downloader.remove(download)
        expect(downloader.downloads).to(beEmpty())
    }

    func testRemoveAll() {
        let downloader = Downloader()
        downloader.add(title: "Title_1", url: Stream.shortOnDemand.url)
        downloader.add(title: "Title_2", url: Stream.shortOnDemand.url)
        downloader.removeAll()
        expect(downloader.downloads).to(beEmpty())
    }
}
