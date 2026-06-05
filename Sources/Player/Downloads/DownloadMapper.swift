//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public protocol DownloadMapper {
    associatedtype Loader: AssetLoader
    associatedtype Store: AssetDownloadStore

    static func storeInput(from input: Loader.Input) -> Store.Input
    static func loaderInput(from input: Store.Input) -> Loader.Input
    static func storeMetadata(from metadata: Loader.Metadata) -> Store.Metadata
}

extension DownloadMapper {
    static func storeMetadata(from metadata: Loader.Metadata?) -> Store.Metadata? {
        guard let metadata else { return nil }
        return storeMetadata(from: metadata)
    }
}

#endif

// swiftlint:enable missing_docs
