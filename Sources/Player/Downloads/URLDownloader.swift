//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Foundation

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class URLDownloader<CustomData>: ObservableObject {
    private let downloadManager: any DownloadManager<URLAssetLoader<CustomData>.Input, CustomData>

    @Published public private(set) var downloads: [Download] = []

    public init<Provider>(
        name: String? = nil,
        providerType: Provider.Type,
        configuration: URLSessionConfiguration
    ) throws where Provider: URLAssetProvider, Provider.CustomData == CustomData {
        let downloader = Downloader(configuration: configuration, store: try URLAssetDownloadStore(name: name, providerType: providerType))
        self.downloadManager = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func addDownload(url: URL, metadata: AssetMetadata<CustomData>, configuration: DownloadConfiguration = .default) -> Download {
        downloadManager.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    public func download(url: URL, metadata: AssetMetadata<CustomData>) -> Download? {
        downloadManager.download(matching: .init(url: url, metadata: metadata))
    }

    public func playerItem(
        for download: Download,
        trackerAdapters: [TrackerAdapter<AssetMetadata<CustomData>>] = []
    ) -> PlayerItem? {
        downloadManager.playerItem(for: download, trackerAdapters: trackerAdapters)
    }

    public func removeDownload(_ download: Download) {
        downloadManager.removeDownload(download)
    }

    public func removeAllDownloads() {
        downloadManager.removeAllDownloads()
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public extension URLDownloader where CustomData == EmptyCustomData {
    convenience init(name: String? = nil, configuration: URLSessionConfiguration) throws {
        try self.init(name: name, providerType: URLEmptyAssetProvider.self, configuration: configuration)
    }

    @discardableResult
    func addDownload(url: URL, metadata: PlayerMetadata, configuration: DownloadConfiguration = .default) -> Download {
        downloadManager.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    func download(url: URL, metadata: PlayerMetadata) -> Download? {
        downloadManager.download(matching: .init(url: url, metadata: metadata))
    }
}

// swiftlint:enable missing_docs
