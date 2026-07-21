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
    private let session = DownloadSessionMock(name: "DownloadManagerTests")

    func testEmpty() {
        let store = AssetDownloadStoreMock()
        let downloader = Downloader(store: store, session: session)
        expect(downloader.downloads).to(beEmpty())
        expect(store.downloadRecords()).to(beEmpty())
    }

    func testRestore() {
        let store = AssetDownloadStoreMock(preloadedInputs: [
            .playable(url: Stream.download.url)
        ])
        let downloader = Downloader(store: store, session: session)
        expect(downloader.downloads).to(haveCount(1))
        expect(store.downloadRecords()).to(haveCount(1))
    }

    func testAddSingle() {
        let store = AssetDownloadStoreMock()
        let downloader = Downloader(store: store, session: session)
        let download = downloader.addDownload(for: .playable(url: Stream.download.url))
        expect(downloader.downloads).to(equal([download]))
        expect(store.downloadRecords()).to(haveCount(1))
    }

    func testAddDifferent() {
        let store = AssetDownloadStoreMock()
        let downloader = Downloader(store: store, session: session)
        let download1 = downloader.addDownload(for: .playable(url: Stream.download.url))
        let download2 = downloader.addDownload(for: .playable(url: Stream.mediumOnDemand.url))
        expect(download1).notTo(equal(download2))
        expect(downloader.downloads).to(equal([download1, download2]))
        expect(store.downloadRecords()).to(haveCount(2))
    }

    func testAddIdentical() {
        let store = AssetDownloadStoreMock()
        let downloader = Downloader(store: store, session: session)
        let download1 = downloader.addDownload(for: .playable(url: Stream.download.url))
        let download2 = downloader.addDownload(for: .playable(url: Stream.download.url))
        expect(download1).to(equal(download2))
        expect(downloader.downloads).to(equal([download1]))
        expect(store.downloadRecords()).to(haveCount(1))
    }

    func testDownloadWithMatchingInput() {
        let downloader = Downloader(store: AssetDownloadStoreMock(), session: session)
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url)
        let download = downloader.addDownload(for: input)
        expect(downloader.download(matching: input)).to(equal(download))
    }

    func testDownloadWithNonMatchingInput() {
        let downloader = Downloader(store: AssetDownloadStoreMock(), session: session)
        downloader.addDownload(for: .playable(url: Stream.download.url))
        expect(downloader.download(matching: .playable(url: Stream.mediumOnDemand.url))).to(beNil())
    }

    func testRelatedPlayerItem() {
        let downloader = Downloader(store: AssetDownloadStoreMock(), session: session)
        let download = downloader.addDownload(for: .playable(url: Stream.download.url))
        expect(download.state).toEventually(equal(.completed))
        let item = downloader.playerItem(for: download, trackerAdapters: [])
        expect(item).notTo(beNil())
    }

    func testUnrelatedPlayerItem() {
        let downloader1 = Downloader(store: AssetDownloadStoreMock(), session: session)
        let download1 = downloader1.addDownload(for: .playable(url: Stream.download.url))
        expect(download1.state).toEventually(equal(.completed))

        let downloader2 = Downloader(store: AssetDownloadStoreMock(), session: session)
        expect(downloader2.playerItem(for: download1, trackerAdapters: [])).to(beNil())
    }

    func testRemove() {
        let store = AssetDownloadStoreMock()
        let downloader = Downloader(store: store, session: session)
        let download = downloader.addDownload(for: .playable(url: Stream.download.url))
        downloader.removeDownload(download)
        expect(downloader.downloads).to(beEmpty())
        expect(download.state).to(equal(.completed))
        expect(store.downloadRecords()).to(beEmpty())
    }

    func testRemoveUnrelated() {
        let store1 = AssetDownloadStoreMock()
        let downloader1 = Downloader(store: store1, session: session)
        let download1 = downloader1.addDownload(for: .playable(url: Stream.download.url))

        let downloader2 = Downloader(store: AssetDownloadStoreMock(), session: session)
        downloader2.removeDownload(download1)
        expect(download1.state).to(equal(.running))
        expect(store1.downloadRecords()).to(haveCount(1))
    }

    func testRemoveAll() {
        let store = AssetDownloadStoreMock()
        let downloader = Downloader(store: store, session: session)
        let download1 = downloader.addDownload(for: .playable(url: Stream.download.url))
        let download2 = downloader.addDownload(for: .playable(url: Stream.mediumOnDemand.url))
        downloader.removeAllDownloads()
        expect(downloader.downloads).to(beEmpty())
        expect(store.downloadRecords()).to(beEmpty())
        expect(download1.state).to(equal(.completed))
        expect(download2.state).to(equal(.completed))
    }

    func testDeallocation() {
        var downloader: Downloader? = .init(store: AssetDownloadStoreMock(), session: session)
        downloader?.addDownload(for: .playable(url: Stream.download.url))

        weak let weakManager = downloader
        autoreleasepool {
            downloader = nil
        }
        expect(weakManager).to(beNil())
    }
}
