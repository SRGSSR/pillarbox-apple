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
    func testWithoutLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(beSimilarTo(.running))
    }

    func testMetadataLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(beSimilarTo(.preparing))
    }

    func testSessionLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(delay: 0.1),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(beSimilarTo(.preparing))
    }

    func testMetadataAndSessionLatency() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(delay: 0.1),
            store: AssetDownloadStoreMock()
        )
        expect(download.state).to(beSimilarTo(.preparing))
    }

    func testLifeCycleSuccess() {
    }

    func testLifeCycleFailure() {
    }

    func testSuspend() {
    }

    func testResume() {
    }

    func testCancel() {
    }

    func testRestartAfterFailure() {
    }

    func testRestartAfterSuccess() {
    }

    func testExternalFileRemoval() {
    }

    func testRestoreFromRunning() {
    }

    func testRestoreFromEnded() {
    }

    func testRestoreFromFailure() {
    }

    func testProgress() {
    }
}
