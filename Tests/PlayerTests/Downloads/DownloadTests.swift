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
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(equal(.running))
    }

    func testMetadataLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(equal(.preparing))
    }

    func testSessionLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(delay: 0.1),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(equal(.preparing))
    }

    func testMetadataAndSessionLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(delay: 0.1),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(equal(.preparing))
    }

    func testMetadataAndSessionSuccess() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1),
            session: DownloadSessionMock(delay: 0.1),
            store: AssetDownloadStoreMock()
        )
        expectAtLeastEqualPublished(values: [
            .preparing, .running, .completed
        ], from: download.changePublisher(at: \.state).removeDuplicates())
    }

    func testMetadataFailure() {
    }

    func testSessionFailure() {
    }

    func testSuspend() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        download.suspend()
        expect(download.state).to(equal(.suspended))
    }

    func testResume() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        download.suspend()
        expect(download.state).to(equal(.suspended))

        download.resume()
        expect(download.state).to(equal(.running))
    }

    func testRemoveWhilePreparing() {
    }

    func testRemoveWhileRunning() {
    }

    func testCancelWhilePreparing() {
    }

    func testCancelWhileRunning() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(equal(.running))
        download.cancel()
        expect(download.state).to(equal(.completed))
    }

    func testCancelWhileSuspended() {
    }

    func testCancelWhileEnded() {
    }

    func testRestartAfterSuccess() {
    }

    func testRestartAfterFailure() {
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
