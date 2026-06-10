//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum URLAssetMapper: DownloadMapper {
    typealias Loader = URLAssetLoader
    typealias Store = URLAssetDownloadStore

    static func storeInput(from input: URLAssetLoader.Input) -> URLAssetDownloadStore.Input {
        input
    }

    static func loaderInput(from input: URLAssetDownloadStore.Input) -> URLAssetLoader.Input {
        input
    }

    static func storeMetadata(from metadata: String) -> String {
        metadata
    }
}

#endif
