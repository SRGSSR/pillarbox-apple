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
        let publisher = AssetDownloadStoreMock.taskPublisher(
            id: "id",
            input: input,
            reusableAssetMetadata: nil,
            session: session
        )
        let task = try waitForSingleOutput(from: publisher)
        let sessionTask = try unwrap(task.result)
        expect(sessionTask.taskDescription).to(equal("id"))
        expect(task.assetMetadata.playerMetadata).to(equal(metadata))
    }

    func testWithReusableMetadata() throws {
        let metadata = PlayerMetadata(title: "title")
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url)
        let publisher = AssetDownloadStoreMock.taskPublisher(
            id: "id",
            input: input,
            reusableAssetMetadata: .init(playerMetadata: metadata, customData: ()),
            session: session
        )
        let task = try waitForSingleOutput(from: publisher)
        expect(task.result).to(beNil())
        expect(task.assetMetadata.playerMetadata).to(equal(metadata))
    }
}
