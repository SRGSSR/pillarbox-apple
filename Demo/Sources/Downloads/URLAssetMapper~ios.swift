//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum URLAssetMapper: DownloadMapper {
    typealias Loader = URLAssetLoader
    typealias Store = URLAssetDownloadStore

    static func storeInput(from input: URLAssetLoader.Input) -> URLAssetDownloadStore.Input {
        .init(title: input.title, url: input.url)
    }

    static func loaderInput(from input: URLAssetDownloadStore.Input) -> URLAssetLoader.Input {
        .init(title: input.title, url: input.url)
    }

    static func storeMetadata(from metadata: String) -> String {
        metadata
    }
}
