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

private struct MetadataError: Error {}

@available(tvOS, unavailable)
final class DownloadTests: TestCase {
    func testRunningWithImmediatePreparation() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        expect(download.state).to(equal(.running))
        expect(download.progress).to(equal(0))
    }

    func testRunningWithAsynchronousPreparation() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url, after: 0.1))
        expect(download.state).to(equal(.preparing))
        expect(download.progress).to(equal(0))
    }

    func testCompletion() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(delay: 0.1), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url, after: 0.1))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(1))
        expect(download.error).to(beNil())
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        let location = try unwrap(download.location)
        expect(FileManager.default.fileExists(atPath: location.path())).to(beTrue())
    }

    func testSuspend() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        download.suspend()
        expect(download.state).toEventually(equal(.suspended))
    }

    func testResume() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        download.suspend()
        expect(download.state).toEventually(equal(.suspended))

        download.resume()
        expect(download.state).toEventuallyNot(equal(.suspended))
    }

    func testMetadata() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url, metadata: .init(title: "Title"), after: 0.1))
        expect(download.metadata.title).toEventually(equal("Title"))
        expect(download.error).to(beNil())
    }

    func testIgnoreMetadataUpdates() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(
            input: .updatable(url: Stream.largeDownload.url, metadata: .init(title: "Title1"), to: .init(title: "Title2"), after: 0.1)
        )
        expect(download.metadata.title).toAlways(equal("Title1"), until: .milliseconds(200))
    }

    func testMetadataFailure() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .failing(with: MetadataError()))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
    }

    func testSessionFailure() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.unavailableDownload.url))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(0))
        expect(download.error).notTo(beNil())
        expect(download.location).to(beNil())
    }

    func testRemoveWhileInitiallyPreparing() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url, after: 0.1))
        expect(download.state).to(equal(.preparing))

        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(download.progress).to(equal(0))
        expect(download.error).to(beNil())
        expect(download.location).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
    }

    func testRemoveWhileInitiallyRunning() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        expect(download.state).to(equal(.running))

        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(download.progress).to(equal(0))
        expect(download.error).to(beNil())
        expect(download.location).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
    }

    func testRemoveWhileDownloadingFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        let location = try pollUnwrap(download.location)

        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(download.progress).to(equal(0))
        expect(download.error).to(beNil())
        expect(download.location).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(FileManager.default.fileExists(atPath: location.path())).toEventually(beFalse())
    }

    func testRemoveWhileCompleted() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        expect(download.state).toEventually(equal(.completed))
        expect(download.location).notTo(beNil())

        download.remove()
        expect(download.state).toEventually(equal(.cancelled))
        expect(download.progress).to(equal(0))
        expect(download.error).to(beNil())
        expect(download.location).to(beNil())
        expect(store.downloadRecord(forId: download.id)).to(beNil())
    }

    func testRestart() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        expect(download.state).toEventually(equal(.completed))
        let location1 = try unwrap(download.location)

        download.restart()
        expect(download.state).toEventually(equal(.running))
        expect(download.progress).to(equal(0))
        expect(download.state).toEventually(equal(.completed))
        expect(download.progress).to(equal(1))
        let location2 = try unwrap(download.location)
        expect(location1).notTo(equal(location2))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
    }

    func testRestoreRunningWithMissingFile() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMockInput.playable(url: Stream.smallDownload.url)

        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download1 = manager1.addDownload(input: input)
        expect(download1.state).toEventually(equal(.completed))
        let location1 = try unwrap(download1.location)
        try FileManager.default.removeItem(at: location1)

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        expect(download2.progress).to(equal(0))
        expect(download2.error).notTo(beNil())
        expect(download2.location).to(beNil())
    }

    func testRestoreCompleted() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMockInput.playable(url: Stream.smallDownload.url)

        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download1 = manager1.addDownload(input: input)
        expect(download1.state).toEventually(equal(.completed))
        let location1 = try unwrap(download1.location)

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        expect(download2.location).to(equal(location1))
    }

    func testRestoreFailedWithMissingMetadata() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMockInput.failing(with: MetadataError())

        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download1 = manager1.addDownload(input: input)
        expect(download1.state).toEventually(equal(.completed))
        let error1 = try unwrap(download1.error)
        expect(download1.location).to(beNil())

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        let error2 = try unwrap(download2.error)
        expect(error2.localizedDescription).to(equal(error1.localizedDescription))
        expect(download1.location).to(beNil())
    }

    func testRestoreFailedWithMissingFile() throws {
        let store = AssetDownloadStoreMock()
        let input = AssetLoaderMockInput.playable(url: Stream.unavailableDownload.url)

        let manager1 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download1 = manager1.addDownload(input: input)
        expect(download1.state).toEventually(equal(.completed))
        let error1 = try unwrap(download1.error)
        expect(download1.location).to(beNil())

        let manager2 = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download2 = try unwrap(manager2.download(matching: input))
        expect(download2.state).to(equal(.completed))
        let error2 = try unwrap(download2.error)
        expect(error2.localizedDescription).to(equal(error1.localizedDescription))
        expect(download1.location).to(beNil())
    }

    func testNoUserFacingCancellationErrors() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(download.error).to(beNil())
    }
}
