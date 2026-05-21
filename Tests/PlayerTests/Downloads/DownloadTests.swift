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
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty, delay: 0.1),
            session: DownloadSessionMock(delay: 0.1),
            store: AssetDownloadStoreMock()
        )
        expectAtLeastSimilarPublished(values: [
            .preparing, .running, .completed
        ], from: download.changePublisher(at: \.state).removeDuplicates(by: ~~))
    }

    func testLifeCycleFailure() {
    }

    func testMetadata() {
    }

    func testLocation() {
    }

    func testSuspend() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        download.suspend()
        expect(download.state).to(beSimilarTo(.suspended))
    }

    func testResume() {
        let download = Download(
            loaderType: AssetLoaderMock.self,
            input: .init(url: Stream.shortOnDemand.url, metadata: .empty),
            session: DownloadSessionMock(),
            store: AssetDownloadStoreMock()
        )
        download.suspend()
        expect(download.state).to(beSimilarTo(.suspended))

        download.resume()
        expect(download.state).to(beSimilarTo(.running))
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

    func testRestoreWithMissingTask() {
        // TODO: Use inactive DownloadSessionMock that is not able to deliver tasks
    }

    func testRestoreFromEnded() {
    }

    func testRestoreFromFailed() {
    }

    func testProgress() {
    }
}
