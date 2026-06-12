//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation
import PillarboxAnalytics

@_spi(DownloaderPrivate)
import PillarboxPlayer

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class URNDownloader: ObservableObject {
    private let downloader: Downloader<URNAssetDownloadStore>

    @Published public private(set) var downloads: [Download] = []

    public init(configuration: URLSessionConfiguration) {
        let downloader = Downloader(
            assetLoaderType: URNAssetLoader.self,
            storableMetadata: URNDownloader.storableMetadata,
            configuration: configuration,
            store: URNAssetDownloadStore()
        )
        self.downloader = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    private static func storableMetadata(_ metadata: MediaMetadata) -> URNMetadata {
        .init(
            identifier: metadata.mainChapter.urn,
            title: metadata.title,
            subtitle: metadata.subtitle,
            analyticsData: metadata.analyticsData,
            analyticsMetadata: metadata.analyticsMetadata,
        )
    }

    @discardableResult
    public func addDownload(urn: String, server: Server = .production) -> Download {
        downloader.addDownload(for: .init(urn: urn, server: server))
    }

    public func download(urn: String, server: Server) -> Download? {
        downloader.download(matching: .init(urn: urn, server: server))
    }

    public func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<URNMetadata>] = []) -> PlayerItem? {
        let defaultAdapters: [TrackerAdapter<URNMetadata>] = [
            ComScoreTracker.adapter(mapper: \.analyticsData),
            CommandersActTracker.adapter(configuration: nil, mapper: \.analyticsMetadata)
        ]
        return downloader.playerItem(for: download, trackerAdapters: defaultAdapters + trackerAdapters)
    }

    public func removeDownload(_ download: Download) {
        downloader.removeDownload(download)
    }

    public func removeAllDownloads() {
        downloader.removeAllDownloads()
    }
}

#endif

// swiftlint:enable missing_docs
