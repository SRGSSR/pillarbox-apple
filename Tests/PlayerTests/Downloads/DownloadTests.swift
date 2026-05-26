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

@available(tvOS, unavailable)
final class DownloadTests: TestCase {
    // TODO: Also verify entry/cleanup in storage/movpkg from relevant tests

    func testWithoutLatency() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty))
        expect(download.state).to(equal(.running))
    }

    func testWithLatency() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty, delay: 0.1))
        expect(download.state).to(equal(.preparing))
    }

    func testCompletion() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(delay: 0.1), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty, delay: 0.1))
        expect(download.state).toEventually(equal(.completed))
    }

    func testMetadataFailure() {
    }

    func testSessionFailure() {
    }

    func testSuspend() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty))
        download.suspend()
        expect(download.state).to(equal(.suspended))
    }

    func testResume() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty))
        download.suspend()
        expect(download.state).to(equal(.suspended))

        download.resume()
        expect(download.state).to(equal(.running))
    }

    func testRemoveWhilePreparing() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty, delay: 0.1))
        expect(download.state).to(equal(.preparing))
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).toAlways(beNil(), until: .milliseconds(500))
    }

    func testRemoveWhileRunning() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty))
        expect(download.state).to(equal(.running))
        download.remove()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).toAlways(beNil(), until: .milliseconds(500))
    }

    func testRemoveWhileDownloadingFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.largeDownload.url, metadata: .empty))
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
        let download = manager.addDownload(input: .init(url: Stream.smallDownload.url, metadata: .empty))
        expect(download.state).toEventually(equal(.completed))
        expect(download.location).notTo(beNil())
        download.remove()
        expect(download.state).toEventually(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).to(beNil())
        expect(download.location).to(beNil())
    }

    func testRestartWhenCompleted() {
    }

    func testRestartWhenCompletedWithError() {
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
}
