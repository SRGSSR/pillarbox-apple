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
final class AssetDownloadTests: TestCase {
    func testNoSource() throws {
        let playerMetadata = PlayerMetadata(imageSource: .none)
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata)
        let publisher = AssetDownloadStoreMock.downloadConfigurationPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata], from: publisher)
    }

    func testImageSource() throws {
        let playerMetadata = PlayerMetadata(imageSource: .image(Data()))
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata)
        let publisher = AssetDownloadStoreMock.downloadConfigurationPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata], from: publisher)
    }

    func testUrlSource() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: PlayerMetadata(imageSource: .url(standardResolution: url)))
        let publisher = AssetDownloadStoreMock.downloadConfigurationPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [
            PlayerMetadata(imageSource: .image(try Data(contentsOf: url)))
        ], from: publisher)
    }

    func testFailure() {
        let url = URL(string: "https://localhost:8123/missing.jpg")!
        let source = ImageSource.url(standardResolution: url)
        let playerMetadata = PlayerMetadata(imageSource: source)
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata)
        let publisher = AssetDownloadStoreMock.downloadConfigurationPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata], from: publisher)
    }

    func testIgnoreMetadataUpdate() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let playerMetadata1 = PlayerMetadata(imageSource: .none)
        let playerMetadata2 = PlayerMetadata(imageSource: .image(try Data(contentsOf: url)))
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata1, updatedWithMetadata: playerMetadata2)
        let publisher = AssetDownloadStoreMock.downloadConfigurationPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata1], from: publisher)
    }
}
