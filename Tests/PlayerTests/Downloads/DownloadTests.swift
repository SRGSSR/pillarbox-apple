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
    override static func setUp() {
        URLCache.shared.removeAllCachedResponses()
    }

    // TODO: Also verify entry/cleanup in storage/movpkg from relevant tests

    func testWithoutLatency() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download.state).to(equal(.running))
    }

    func testWithLatency() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1))
        expect(download.state).to(equal(.preparing))
    }

    func testMetadataAndSessionSuccess() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(delay: 0.1), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1))
        expectAtLeastEqualPublished(values: [
            .preparing, .running, .completed
        ], from: download.changePublisher(at: \.state).removeDuplicates())
    }

    func testMetadataFailure() {
    }

    func testSessionFailure() {
    }

    func testSuspend() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download.suspend()
        expect(download.state).to(equal(.suspended))
    }

    func testResume() {
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: AssetDownloadStoreMock())
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download.suspend()
        expect(download.state).to(equal(.suspended))

        download.resume()
        expect(download.state).to(equal(.running))
    }

    func testCancelWhilePreparing() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1))
        expect(download.state).to(equal(.preparing))
        download.cancel()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        expect(download.location).toAlways(beNil(), until: .milliseconds(500))
    }

    func testCancelWhileRunning() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download.state).to(equal(.running))
        download.cancel()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        expect(download.location).toAlways(beNil(), until: .milliseconds(500))
    }

    func testCancelWhileDownloadingFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let location = try pollUnwrap(download.location)
        download.cancel()
        expect(download.state).to(equal(.cancelled))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        expect(download.location).to(beNil())
        expect(FileManager.default.fileExists(atPath: location.path())).to(beFalse())
    }

    func testCancelWhileCompleted() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download.state).toEventually(equal(.completed))
        expect(download.location).notTo(beNil())
        download.cancel()
        expect(download.state).toEventually(equal(.completed))
        expect(store.downloadRecord(forId: download.id)).notTo(beNil())
        let location = try unwrap(download.location)
        expect(FileManager.default.fileExists(atPath: location.path())).to(beTrue())
    }

    func testCancelWhileCancelled() {
    }

    func testRemoveWhilePreparing() {
    }

    func testRemoveWhileRunning() {
    }

    func testRemoveWhileDownloadingFile() {
    }

    func testRemoveWhileCompleted() {
    }

    func testRemoveWhileCancelled() {
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
