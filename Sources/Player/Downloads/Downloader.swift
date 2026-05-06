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
public final class Downloader<A>: ObservableObject where A: AssetDownloader {
    private let manager: DownloadManager<A>

    @Published public private(set) var downloads: [Download<A>] = []

    public init(downloader: A) {
        manager = DownloadManager(downloader: downloader)
        manager.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func add(input: A.Loader.Input) -> Download<A> {
        manager.add(input: input)
    }

    public func remove(_ download: Download<A>) {
        manager.remove(download)
    }

    public func removeAll() {
        manager.removeAll()
    }
}

#endif

// swiftlint:enable missing_docs
