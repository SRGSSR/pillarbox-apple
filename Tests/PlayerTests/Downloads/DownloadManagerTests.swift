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
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        expect(manager.downloads).to(beEmpty())
        expect(store.downloadRecords()).to(beEmpty())
    }

    func testRestore() {
        let store = AssetDownloadStoreMock(preloadedInputs: [
            .playable(url: Stream.download.url)
        ])
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        expect(manager.downloads).to(haveCount(1))
        expect(store.downloadRecords()).to(haveCount(1))
    }

    func testAddSingle() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download = manager.addDownload(input: .playable(url: Stream.download.url))
        expect(manager.downloads).to(equal([download]))
        expect(store.downloadRecords()).to(haveCount(1))
    }

    func testAddDifferent() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download1 = manager.addDownload(input: .playable(url: Stream.download.url))
        let download2 = manager.addDownload(input: .playable(url: Stream.mediumOnDemand.url))
        expect(download1).notTo(equal(download2))
        expect(manager.downloads).to(equal([download1, download2]))
        expect(store.downloadRecords()).to(haveCount(2))
    }

    func testAddIdentical() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download1 = manager.addDownload(input: .playable(url: Stream.download.url))
        let download2 = manager.addDownload(input: .playable(url: Stream.download.url))
        expect(download1).to(equal(download2))
        expect(manager.downloads).to(equal([download1]))
        expect(store.downloadRecords()).to(haveCount(1))
    }

    func testDownloadWithMatchingInput() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: AssetDownloadStoreMock())
        let input = AssetLoaderMockInput.playable(url: Stream.download.url)
        let download = manager.addDownload(input: input)
        expect(manager.download(matching: input)).to(equal(download))
    }

    func testDownloadWithNonMatchingInput() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: AssetDownloadStoreMock())
        manager.addDownload(input: .playable(url: Stream.download.url))
        expect(manager.download(matching: .playable(url: Stream.mediumOnDemand.url))).to(beNil())
    }

    func testRelatedPlayerItem() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.download.url))
        expect(download.state).toEventually(equal(.completed))
        let item = manager.playerItem(for: download, trackerAdapters: [
            PlayerItemTrackerMock.adapter(configuration: .init())
        ])
        expect(item).notTo(beNil())
        expect(item?.trackerAdapters.count).to(equal(1))
    }

    func testUnrelatedPlayerItem() {
        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: AssetDownloadStoreMock())
        let download1 = manager1.addDownload(input: .playable(url: Stream.download.url))
        expect(download1.state).toEventually(equal(.completed))

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: AssetDownloadStoreMock())
        expect(manager2.playerItem(for: download1, trackerAdapters: [])).to(beNil())
    }

    func testRemove() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download = manager.addDownload(input: .playable(url: Stream.download.url))
        manager.removeDownload(download)
        expect(manager.downloads).to(beEmpty())
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecords()).to(beEmpty())
    }

    func testRemoveUnrelated() {
        let store1 = AssetDownloadStoreMock()
        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store1)
        let download1 = manager1.addDownload(input: .playable(url: Stream.download.url))

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: AssetDownloadStoreMock())
        manager2.removeDownload(download1)
        expect(download1.state).to(equal(.running))
        expect(store1.downloadRecords()).to(haveCount(1))
    }

    func testRemoveAll() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download1 = manager.addDownload(input: .playable(url: Stream.download.url))
        let download2 = manager.addDownload(input: .playable(url: Stream.mediumOnDemand.url))
        manager.removeAllDownloads()
        expect(manager.downloads).to(beEmpty())
        expect(store.downloadRecords()).to(beEmpty())
        expect(download1.state).to(equal(.cancelled))
        expect(download2.state).to(equal(.cancelled))
    }
}
