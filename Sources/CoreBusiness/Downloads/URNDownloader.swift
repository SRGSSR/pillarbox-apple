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

    public init(name: String? = nil, configuration: URLSessionConfiguration) throws {
        let downloader = Downloader(
            assetLoaderType: URNAssetLoader.self,
            configuration: configuration,
            store: try URNAssetDownloadStore(name: name)
        )
        self.downloader = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func addDownload(urn: String, server: Server = .production, httpHeaders: [String: String] = [:]) -> Download {
        downloader.addDownload(for: .init(urn: urn, server: server, httpHeaders: httpHeaders))
    }

    public func download(urn: String, server: Server) -> Download? {
        downloader.download(matching: .init(urn: urn, server: server, httpHeaders: [:]))
    }

    public func playerItem(
        for download: Download,
        commandersActSource: CommandersActSource? = nil,
        trackerAdapters: [TrackerAdapter<AssetMetadata<URNMetadata>>] = []
    ) -> PlayerItem? {
        downloader.playerItem(for: download, trackerAdapters: [
            ComScoreTracker.adapter(mapper: \.customData.analyticsData),
            CommandersActTracker.adapter(configuration: commandersActSource, mapper: \.customData.analyticsMetadata)
        ] + trackerAdapters)
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
