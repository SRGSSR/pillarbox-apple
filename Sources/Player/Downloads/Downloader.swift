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
public final class Downloader<L, S>: ObservableObject where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
    private let manager: DownloadManager<L, S>

    @Published public private(set) var downloads: [Download<L, S>] = []

    public init(loaderType: L.Type, configuration: URLSessionConfiguration, store: S) {
        manager = DownloadManager(loaderType: loaderType, configuration: configuration, store: store)
        manager.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func add(input: S.Input) -> Download<L, S> {
        manager.add(input: input)
    }

    public func remove(_ download: Download<L, S>) {
        manager.remove(download)
    }

    public func removeAll() {
        manager.removeAll()
    }
}

#endif

// swiftlint:enable missing_docs
