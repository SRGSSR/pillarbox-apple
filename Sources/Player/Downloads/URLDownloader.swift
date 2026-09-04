//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Foundation

// TODO: Type erasure. Should have CustomData instead of Provider as generic parameter
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class URLDownloader<Provider>: ObservableObject where Provider: URLOfflineAssetProvider {
    private let downloader: Downloader<URLAssetDownloadStore<Provider>>

    @Published public private(set) var downloads: [Download] = []

    public init(
        name: String? = nil,
        assetProviderType: Provider.Type,
        configuration: URLSessionConfiguration
    ) throws {
        let downloader = Downloader(configuration: configuration, store: try URLAssetDownloadStore(name: name, assetProviderType: assetProviderType))
        self.downloader = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func addDownload(url: URL, metadata: AssetMetadata<Provider.CustomData>, configuration: DownloadConfiguration = .default) -> Download {
        downloader.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    public func download(url: URL, metadata: AssetMetadata<Provider.CustomData>) -> Download? {
        downloader.download(matching: .init(url: url, metadata: metadata))
    }

    public func playerItem(
        for download: Download,
        trackerAdapters: [TrackerAdapter<AssetMetadata<Provider.CustomData>>] = []
    ) -> PlayerItem? {
        downloader.playerItem(for: download, trackerAdapters: trackerAdapters)
    }

    public func removeDownload(_ download: Download) {
        downloader.removeDownload(download)
    }

    public func removeAllDownloads() {
        downloader.removeAllDownloads()
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public extension URLDownloader where Provider == URLEmptyAssetProvider {
    convenience init(name: String? = nil, configuration: URLSessionConfiguration) throws {
        try self.init(name: name, assetProviderType: URLEmptyAssetProvider.self, configuration: configuration)
    }

    @discardableResult
    func addDownload(url: URL, metadata: PlayerMetadata, configuration: DownloadConfiguration = .default) -> Download {
        downloader.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    func download(url: URL, metadata: PlayerMetadata) -> Download? {
        downloader.download(matching: .init(url: url, metadata: metadata))
    }
}

// swiftlint:enable missing_docs
