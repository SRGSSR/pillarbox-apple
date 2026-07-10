//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
@testable import PillarboxPlayer

import Foundation
import Nimble
import PillarboxStreams

@available(tvOS, unavailable)
final class DownloadTaskTests: TestCase {
    private let session = DownloadSessionMock(name: "DownloadTests")

    func testWithoutReusableMetadata() throws {
        let metadata = PlayerMetadata(title: "title")
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: metadata)
        let id = AssetDownloadStoreMock.id(from: input)
        let publisher = AssetDownloadStoreMock.downloadTaskPublisher(
            input: input,
            reusableAssetMetadata: nil,
            session: session
        )
        let downloadTask = try waitForSingleOutput(from: publisher)
        let task = try unwrap(downloadTask.task)
        expect(task.taskDescription).to(equal(id))
        expect(downloadTask.assetMetadata.playerMetadata).to(equal(metadata))
    }

    func testWithReusableMetadata() throws {
        let metadata = PlayerMetadata(title: "title")
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url)
        let publisher = AssetDownloadStoreMock.downloadTaskPublisher(
            input: input,
            reusableAssetMetadata: .init(playerMetadata: metadata, customData: ()),
            session: session
        )
        let downloadTask = try waitForSingleOutput(from: publisher)
        expect(downloadTask.task).to(beNil())
        expect(downloadTask.assetMetadata.playerMetadata).to(equal(metadata))
    }
}
