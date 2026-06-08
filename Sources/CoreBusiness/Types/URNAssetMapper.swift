//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

// swiftlint:disable missing_docs

@available(iOS 17.0, *)
@_spi(DownloaderPrivate)
public enum URNAssetMapper: DownloadMapper {
    public typealias Loader = URNAssetLoader
    public typealias Store = URNAssetDownloadStore

    public static func storeInput(from input: URNAssetLoader.Input) -> URNAssetDownloadStore.Input {
        .init(urn: input.urn, server: input.server, configuration: input.configuration)
    }

    public static func loaderInput(from input: URNAssetDownloadStore.Input) -> URNAssetLoader.Input {
        .init(urn: input.urn, server: input.server, configuration: input.configuration)
    }

    public static func storeMetadata(from metadata: MediaMetadata) -> URNAssetDownloadStore.EntryMetadata {
        .init(
            identifier: metadata.mainChapter.urn,
            title: metadata.title,
            subtitle: metadata.subtitle
        )
    }
}

// swiftlint:enable missing_docs
