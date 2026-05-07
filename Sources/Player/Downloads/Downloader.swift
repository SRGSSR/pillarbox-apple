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
public final class Downloader<L, A>: ObservableObject where L: AssetLoader, A: AssetDownloadStore, L.Input == A.Input, L.Metadata == A.Metadata {
    private let manager: DownloadManager<L, A>

    @Published public private(set) var downloads: [Download<L, A>] = []

    public init(loaderType: L.Type, downloader: A) {
        manager = DownloadManager(downloader: downloader)
        manager.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func add(input: A.Input) -> Download<L, A> {
        manager.add(input: input)
    }

    public func remove(_ download: Download<L, A>) {
        manager.remove(download)
    }

    public func removeAll() {
        manager.removeAll()
    }
}

#endif

// swiftlint:enable missing_docs
