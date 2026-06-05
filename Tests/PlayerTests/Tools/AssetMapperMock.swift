//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum AssetMapperMock: DownloadMapper {
    typealias Loader = AssetLoaderMock
    typealias Store = AssetDownloadStoreMock

    static func storeInput(from input: AssetLoaderMockInput) -> AssetLoaderMockInput {
        input
    }

    static func loaderInput(from input: AssetLoaderMockInput) -> AssetLoaderMockInput {
        input
    }

    static func storeMetadata(from metadata: PlayerMetadata) -> PlayerMetadata {
        metadata
    }
}
