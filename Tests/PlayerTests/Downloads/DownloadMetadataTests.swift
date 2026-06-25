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
final class DownloadMetadataTests: TestCase {
    func testNoSource() throws {
        let playerMetadata = PlayerMetadata(imageSource: .none)
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata)
        let publisher = AssetDownloadStoreMock.downloadMetadataPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata], from: publisher)
    }

    func testImageSource() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let image = try unwrap(UIImage(contentsOfFile: url.path()))
        let playerMetadata = PlayerMetadata(imageSource: .image(image))
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata)
        let publisher = AssetDownloadStoreMock.downloadMetadataPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata], from: publisher)
    }

    func testUrlSource() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let image = try unwrap(UIImage(contentsOfFile: url.path()))
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: PlayerMetadata(imageSource: .url(standardResolution: url)))
        let publisher = AssetDownloadStoreMock.downloadMetadataPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [
            PlayerMetadata(imageSource: .image(image))
        ], from: publisher)
    }

    func testFailure() {
        let url = URL(string: "https://localhost:8123/missing.jpg")!
        let source = ImageSource.url(standardResolution: url)
        let playerMetadata = PlayerMetadata(imageSource: source)
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata)
        let publisher = AssetDownloadStoreMock.downloadMetadataPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata], from: publisher)
    }

    func testIgnoreMetadataUpdate() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let image = try unwrap(UIImage(contentsOfFile: url.path()))
        let playerMetadata1 = PlayerMetadata(imageSource: .none)
        let playerMetadata2 = PlayerMetadata(imageSource: .image(image))
        let input = AssetLoaderMock.Input.playable(url: Stream.download.url, metadata: playerMetadata1, updatedWithMetadata: playerMetadata2)
        let publisher = AssetDownloadStoreMock.downloadMetadataPublisher(for: input)
            .map(\.assetMetadata.playerMetadata)
        expectOnlyEqualPublished(values: [playerMetadata1], from: publisher)
    }
}
