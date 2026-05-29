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
final class DownloadPlayerItemTests: TestCase {
    func testItemFromDownloadWithoutFile() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        expect(PlayerItem(download: download, store: store)).to(beNil())
    }

    func testItemFromDownloadWithFile() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: DownloadSessionMock(), store: store)
        let download = manager.addDownload(input: .playable(url: Stream.largeDownload.url))
        expect(download.location).toEventuallyNot(beNil())
        expect(PlayerItem(download: download, store: store)).notTo(beNil())
    }
}
