//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Combine
import Foundation

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Downloader: ObservableObject {
    private static let manager = DownloadManager()

    @Published public private(set) var downloads: [Download] = []

    public init() {
        Self.manager.$downloads
            .assign(to: &$downloads)
    }

//    @discardableResult
//    public func add(title: String, url: URL) -> Download {
//        Self.manager.add(title: title, url: url)
//    }

    @discardableResult
    public func add<A>(assetLoaderType: A.Type, input: A.Input) -> Download where A: DownloadableAssetLoader {
        Self.manager.add(assetLoaderType: assetLoaderType, input: input)
    }

    @discardableResult
    public func add(url: URL, metadata: PlayerMetadata) -> Download {
        Self.manager.add(
            assetLoaderType: SimpleAssetLoader.self,
            input: .init(
                url: url,
                metadata: metadata,
                configuration: .default
            )
        )
    }

    public func remove(_ download: Download) {
        Self.manager.remove(download)
    }

    public func removeAll() {
        Self.manager.removeAll()
    }
}

#endif

// swiftlint:enable missing_docs
