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
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        expect(manager.downloads).to(beEmpty())
    }

    func testRestore() {
        let manager = DownloadManager(
            loaderType: AssetLoaderMock.self,
            sessionProvider: .custom(DownloadSessionMock()),
            store: AssetDownloadStoreMock(preloadedInputs: [
                .init(url: Stream.shortOnDemand.url, metadata: .empty)
            ])
        )
        expect(manager.downloads).notTo(beEmpty())
    }

    func testAddSingle() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(manager.downloads).to(equal([download]))
    }

    func testAddMany() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download1 = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.add(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        expect(download1).notTo(equal(download2))
        expect(manager.downloads).to(equal([download1, download2]))
    }

    func testAddIdentical() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download1 = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download1).to(equal(download2))
        expect(manager.downloads).to(equal([download1]))
    }

    func testDownloadWithMatchingInput() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let input = AssetLoaderMock.Input(url: Stream.shortOnDemand.url, metadata: .empty)
        let download = manager.add(input: input)
        expect(manager.download(matching: input)).to(equal(download))
    }

    func testDownloadWithNonMatchingInput() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(manager.download(matching: .init(url: Stream.mediumOnDemand.url, metadata: .empty))).to(beNil())
    }

    func testRelatedPlayerItem() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download.attach(to: URL(filePath: "file"))
        expect(manager.playerItem(for: download, trackerAdapters: [])).notTo(beNil())
    }

    func testUnrelatedPlayerItem() {
        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download1 = manager1.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download1.attach(to: URL(filePath: "file"))

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        expect(manager2.playerItem(for: download1, trackerAdapters: [])).to(beNil())
    }

    func testRemove() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        manager.remove(download)
        expect(manager.downloads).to(beEmpty())
    }

    func testRemoveUnrelated() {
        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        let download1 = manager1.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        manager2.remove(download1)
        expect(download1.state).to(equal(.running))
    }

    func testRemoveAll() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, sessionProvider: .custom(DownloadSessionMock()), store: AssetDownloadStoreMock())
        manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        manager.add(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        manager.removeAll()
        expect(manager.downloads).to(beEmpty())
    }
}
