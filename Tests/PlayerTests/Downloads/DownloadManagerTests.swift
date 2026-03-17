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

@available(tvOS, unavailable)
final class DownloadManagerTests: TestCase {
    func testEmpty() {
        expect(DownloadManager().downloads).to(beEmpty())
    }

    func testAdd() {
        let manager = DownloadManager()
        let download = manager.add(title: "Title", url: Stream.shortOnDemand.url)
        expect(manager.downloads).to(equal([download]))
    }

    func testRemove() {
        let manager = DownloadManager()
        let download = manager.add(title: "Title", url: Stream.shortOnDemand.url)
        manager.remove(download)
        expect(manager.downloads).to(beEmpty())
    }

    func testRemoveAll() {
        let manager = DownloadManager()
        manager.add(title: "Title_1", url: Stream.shortOnDemand.url)
        manager.add(title: "Title_2", url: Stream.shortOnDemand.url)
        manager.removeAll()
        expect(manager.downloads).to(beEmpty())
    }
}
