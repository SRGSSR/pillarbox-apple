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
final class DownloaderTests: TestCase {
    func testEmpty() {
        let manager = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        expect(manager.downloads).to(beEmpty())
    }

    func testAddSingle() {
        let manager = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(manager.downloads).to(equal([download]))
    }

    func testAddMany() {
        let manager = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download1 = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.add(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        expect(download1).notTo(equal(download2))
        expect(manager.downloads).to(equal([download1, download2]))
    }

    func testAddIdentical() {
        let manager = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download1 = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download1).to(equal(download2))
        expect(manager.downloads).to(equal([download1]))
    }

    func testDownloadWithMatchingInput() {
    }

    func testDownloadWithNonMatchingInput() {
    }

    func testPlayerItemForDownload() {
    }

    func testPlayerItemForUnrelatedDownload() {
    }

    func testRemove() {
        let manager = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download = manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        manager.remove(download)
        expect(manager.downloads).to(beEmpty())
    }

    func testRemoveAll() {
        let manager = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        manager.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        manager.add(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        manager.removeAll()
        expect(manager.downloads).to(beEmpty())
    }
}
