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
    private let session = DownloadSessionMock(name: "DownloadPlayerItemTests")

    func testItemFromDownloadWithoutFile() {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download = manager.addDownload(input: .playable(url: Stream.download.url))
        expect(PlayerItem(download: download, store: store)).to(beNil())
    }

    func testItemFromDownloadWithFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download = manager.addDownload(input: .playable(url: Stream.download.url))
        expect(download.location).toEventuallyNot(beNil())

        let item = try unwrap(PlayerItem(download: download, store: store))
        let player = Player(item: item)
        expect(player.playbackState).toEventually(equal(.paused))
    }

    func testItemFromDownloadWithRemovedFile() throws {
        let store = AssetDownloadStoreMock()
        let manager = DownloadManager(loaderType: AssetLoaderMock.self, session: session, store: store)
        let download = manager.addDownload(input: .playable(url: Stream.download.url))
        expect(download.state).toEventually(equal(.completed))
        let location = try unwrap(download.location)
        try FileManager.default.removeItem(at: location)

        let item = try unwrap(PlayerItem(download: download, store: store))
        let player = Player(item: item)
        expect(player.error).toEventuallyNot(beNil())
    }
}
