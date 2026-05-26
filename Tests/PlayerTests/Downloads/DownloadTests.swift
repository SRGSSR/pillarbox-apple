//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams
import XCTest

private struct MetadataError: Error {}

@available(tvOS, unavailable)
final class DownloadTests: TestCase {
    // TODO: Also verify entry/cleanup in storage/movpkg from relevant tests

    func testWithoutLatency() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        expect(download.state).to(equal(.running))
    }

    func testWithLatency() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url, after: 0.1))
        expect(download.state).to(equal(.preparing))
    }

    func testCompletion() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(delay: 0.1), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url, after: 0.1))
        expect(download.state).toEventually(equal(.completed))
    }

    func testMetadata() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url, metadata: .init(title: "Title"), after: 0.1))
        expect(download.metadata.title).toEventually(equal("Title"))
        expect(download.error).to(beNil())
    }

    func testMetadataFailure() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .failing(with: MetadataError()))
        expect(download.state).toEventually(equal(.completed))
        expect(download.error).notTo(beNil())
    }

    func testSessionFailure() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.missingDownload.url))
        expect(download.state).toEventually(equal(.completed))
        expect(download.error).notTo(beNil())
    }

    func testSuspend() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        download.suspend()
        expect(download.state).to(equal(.suspended))
    }

    func testResume() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        download.suspend()
        expect(download.state).to(equal(.suspended))

        download.resume()
        expect(download.state).to(equal(.running))
    }

    func testRemoveWhilePreparing() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url, after: 0.1))
        expect(download.state).to(equal(.preparing))
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).toAlways(beNil(), until: .milliseconds(500))
    }

    func testRemoveWhileRunning() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        expect(download.state).to(equal(.running))
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).toAlways(beNil(), until: .milliseconds(500))
    }

    func testRemoveWhileDownloadingFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        let location = try pollUnwrap(timeout: .seconds(5)) {
            download.location
        }
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).to(beNil())
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
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).to(beNil())
    }

    func testRestart() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        expect(download.state).toEventually(equal(.completed))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        let location1 = try unwrap(download.location)
        download.restart()
        expect(download.state).toEventually(equal(.running))
        expect(download.state).toEventually(equal(.completed))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        let location2 = try unwrap(download.location)
        expect(location1).notTo(equal(location2))
    }

    func testRestoreRunning() {
    }

    func testRestoreRunningWithMissingFile() {
    }

    func testRestoreRunningWithMissingTask() {
    }

    func testRestoreEnded() {
    }

    func testRestoreFailed() {
    }

    func testNonUserFacingCancellationErrors() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .playable(url: Stream.smallDownload.url))
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(download.error).to(beNil())
    }
}
