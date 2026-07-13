//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import Foundation
import Nimble
import PillarboxStreams

private struct MetadataError: Error {}

@available(tvOS, unavailable)
final class DownloadTests: TestCase {
    private let session = DownloadSessionMock(name: "DownloadTests")

    func testRunningWithImmediatePreparation() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        expect(download.state).to(equal(.running))
        expect(download.progress).to(equal(0))
    }

    func testRunningWithAsynchronousPreparation() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url, after: 0.1))
        expect(download.state).to(equal(.preparing))
        expect(download.progress).to(equal(0))
    }

    func testCompletion() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url, after: 0.1))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(1))
        expect(download.error).to(beNil())
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        let fileUrl = try unwrap(download.fileUrl)
        expect(FileManager.default.fileExists(atPath: fileUrl.path())).to(beTrue())
    }

    func testSuspend() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        download.suspend()
        expect(download.state).toEventually(equal(.suspended))
    }

    func testResume() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        download.suspend()
        expect(download.state).toEventually(equal(.suspended))

        download.resume()
        expect(download.state).toEventuallyNot(equal(.suspended))
    }

    func testMetadata() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url, metadata: .init(title: "Title"), after: 0.1))
        expect(download.metadata.title).to(beNil())
        expect(download.metadata.title).toEventually(equal("Title"))
        expect(download.error).to(beNil())
    }

    func testIgnoreMetadataUpdates() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(
            for: .playable(url: Stream.download.url, metadata: .init(title: "Title1"), updatedWithMetadata: .init(title: "Title2"), interval: 0.1)
        )
        expect(download.metadata.title).toAlways(equal("Title1"), until: .milliseconds(200))
    }

    func testMetadataFailure() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .failing(with: MetadataError()))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
    }

    func testSessionFailure() {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        let download = manager.addDownload(for: .playable(url: Stream.unavailableDownload.url))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
        expect(download.fileUrl).to(beNil())
    }

    func testRemoveWhileInitiallyPreparing() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url, after: 0.1))
        expect(download.state).to(equal(.preparing))

        download.remove()
        expect(download.state).to(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
        expect(download.fileUrl).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
    }

    func testRemoveWhileInitiallyRunning() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        expect(download.state).to(equal(.running))

        download.remove()
        expect(download.state).to(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
        expect(download.fileUrl).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
    }

    func testRemoveWhileDownloadingFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        let fileUrl = try pollUnwrap(download.fileUrl)

        download.remove()
        expect(download.state).to(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
        expect(download.fileUrl).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(FileManager.default.fileExists(atPath: fileUrl.path())).toEventually(beFalse())
    }

    func testRemoveWhileCompleted() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        expect(download.state).toEventually(equal(.completed))
        expect(download.fileUrl).notTo(beNil())

        download.remove()
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
        expect(download.fileUrl).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
    }

    func testRestart() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download = manager.addDownload(for: .playable(url: Stream.download.url))
        expect(download.state).toEventually(equal(.completed))
        let location1 = try unwrap(download.fileUrl)

        download.restart()
        expect(download.state).toEventually(equal(.running))
        expect(download.progress).to(equal(0))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(1))
        let location2 = try unwrap(download.fileUrl)
        expect(location1).notTo(equal(location2))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
    }

    func testRestoreRunningWithMissingFile() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url)

        let manager1 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download1 = manager1.addDownload(for: input)
        expect(download1.state).toEventually(equal(.completed))
        let location1 = try unwrap(download1.fileUrl)
        try FileManager.default.removeItem(at: location1)

        let manager2 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        expect(download2.progress).to(equal(0))
        expect(download2.error).notTo(beNil())
        expect(download2.fileUrl).to(beNil())
    }

    func testRestoreCompleted() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url)

        let manager1 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download1 = manager1.addDownload(for: input)
        expect(download1.state).toEventually(equal(.completed))
        let location1 = try unwrap(download1.fileUrl)

        let manager2 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        expect(download2.fileUrl).to(equal(location1))
    }

    func testRestoreFailedWithMissingMetadata() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMock.Input.failing(with: MetadataError())

        let manager1 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download1 = manager1.addDownload(for: input)
        expect(download1.state).toEventually(equal(.completed))
        let error1 = try unwrap(download1.error)
        expect(download1.fileUrl).to(beNil())

        let manager2 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        let error2 = try unwrap(download2.error)
        expect(error2.localizedDescription).to(equal(error1.localizedDescription))
        expect(download1.fileUrl).to(beNil())
    }

    func testRestoreFailedWithMissingFile() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMock.Input.playable(url: Stream.unavailableDownload.url)

        let manager1 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download1 = manager1.addDownload(for: input)
        expect(download1.state).toEventually(equal(.completed))
        let error1 = try unwrap(download1.error)
        expect(download1.fileUrl).to(beNil())

        let manager2 = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: store, session: session)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        let error2 = try unwrap(download2.error)
        expect(error2.localizedDescription).to(equal(error1.localizedDescription))
        expect(download1.fileUrl).to(beNil())
    }

    func testDeallocationWithManager() throws {
        var manager: DownloadManager? = .init(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        weak let weakDownload = try unwrap(manager?.addDownload(for: .playable(url: Stream.download.url)))
        autoreleasepool {
            manager = nil
        }
        expect(weakDownload).to(beNil())
    }

    func testDeallocationOnRemoval() throws {
        let manager = DownloadManager(assetLoaderType: AssetLoaderMock.self, store: AssetDownloadStoreMock(), session: session)
        weak let weakDownload = try unwrap(manager.addDownload(for: .playable(url: Stream.download.url)))
        autoreleasepool {
            if let weakDownload {
                manager.removeDownload(weakDownload)
            }
        }
        expect(weakDownload).to(beNil())
    }
}
