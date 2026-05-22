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
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        expect(manager.downloads).to(beEmpty())
    }

    func testRestore() {
        let manager = DownloadManager(
            loaderType: AssetLoaderMock.self,
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock(preloadedInputs: [
                .init(url: Stream.shortOnDemand.url, metadata: .empty)
            ])
        )
        expect(manager.downloads).notTo(beEmpty())
    }

    func testAddSingle() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(manager.downloads).to(equal([download]))
    }

    func testAddMany() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download1 = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.addDownload(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        expect(download1).notTo(equal(download2))
        expect(manager.downloads).to(equal([download1, download2]))
    }

    func testAddIdentical() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download1 = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download1).to(equal(download2))
        expect(manager.downloads).to(equal([download1]))
    }

    func testDownloadWithMatchingInput() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let input = AssetLoaderMock.Input(url: Stream.shortOnDemand.url, metadata: .empty)
        let download = manager.addDownload(input: input)
        expect(manager.download(matching: input)).to(equal(download))
    }

    func testDownloadWithNonMatchingInput() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(manager.download(matching: .init(url: Stream.mediumOnDemand.url, metadata: .empty))).to(beNil())
    }

    func testRelatedPlayerItem() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download.attach(to: URL(filePath: "file"))
        let item = manager.playerItem(for: download, trackerAdapters: [
            PlayerItemTrackerMock.adapter(configuration: .init())
        ])
        expect(item).notTo(beNil())
        expect(item?.trackerAdapters.count).to(equal(1))
    }

    func testUnrelatedPlayerItem() {
        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download1 = manager1.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download1.attach(to: URL(filePath: "file"))

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        expect(manager2.playerItem(for: download1, trackerAdapters: [])).to(beNil())
    }

    func testRemove() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        manager.removeDownload(download)
        expect(manager.downloads).to(beEmpty())
        expect(download.state).to(equal(.cancelled))
    }

    func testRemoveUnrelated() {
        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download1 = manager1.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        manager2.removeDownload(download1)
        expect(download1.state).to(equal(.running))
    }

    func testRemoveAll() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download1 = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.addDownload(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        manager.removeAllDownloads()
        expect(manager.downloads).to(beEmpty())
        expect(download1.state).to(equal(.cancelled))
        expect(download2.state).to(equal(.cancelled))
    }
}
