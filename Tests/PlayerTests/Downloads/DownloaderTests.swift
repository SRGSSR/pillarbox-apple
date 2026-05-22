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
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        expect(downloader.downloads).to(beEmpty())
    }

    func testRestore() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock(preloadedInputs: [
                .init(url: Stream.shortOnDemand.url, metadata: .empty)
            ])
        )
        expect(downloader.downloads).notTo(beEmpty())
    }

    func testAddSingle() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download = downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(downloader.downloads).to(equal([download]))
    }

    func testAddMany() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download1 = downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = downloader.add(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        expect(download1).notTo(equal(download2))
        expect(downloader.downloads).to(equal([download1, download2]))
    }

    func testAddIdentical() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download1 = downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        let download2 = downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(download1).to(equal(download2))
        expect(downloader.downloads).to(equal([download1]))
    }

    func testDownloadWithMatchingInput() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let input = AssetLoaderMock.Input(url: Stream.shortOnDemand.url, metadata: .empty)
        let download = downloader.add(input: input)
        expect(downloader.download(matching: input)).to(equal(download))
    }

    func testDownloadWithNonMatchingInput() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        expect(downloader.download(matching: .init(url: Stream.mediumOnDemand.url, metadata: .empty))).to(beNil())
    }

    func testRelatedPlayerItem() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download = downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download.attach(to: URL(filePath: "file"))
        expect(downloader.playerItem(for: download)).notTo(beNil())
    }

    func testUnrelatedPlayerItem() {
        let downloader1 = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads1"),
            store: AssetDownloadStoreMock()
        )
        let download1 = downloader1.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        download1.attach(to: URL(filePath: "file"))

        let downloader2 = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads2"),
            store: AssetDownloadStoreMock()
        )
        expect(downloader2.playerItem(for: download1)).to(beNil())
    }

    func testRemove() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        let download = downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        downloader.remove(download)
        expect(downloader.downloads).to(beEmpty())
    }

    func testRemoveUnrelated() {
        let downloader1 = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads1"),
            store: AssetDownloadStoreMock()
        )
        let download1 = downloader1.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))

        let downloader2 = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads2"),
            store: AssetDownloadStoreMock()
        )
        downloader2.remove(download1)
        expect(downloader1.downloads).to(equal([download1]))
        expect(download1.state).to(equal(.running))
    }

    func testRemoveAll() {
        let downloader = Downloader(
            loaderType: AssetLoaderMock.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox.downloads"),
            store: AssetDownloadStoreMock()
        )
        downloader.add(input: .init(url: Stream.shortOnDemand.url, metadata: .empty))
        downloader.add(input: .init(url: Stream.mediumOnDemand.url, metadata: .empty))
        downloader.removeAll()
        expect(downloader.downloads).to(beEmpty())
    }
}
