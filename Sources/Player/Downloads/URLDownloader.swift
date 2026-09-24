//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An [observable object](https://developer.apple.com/documentation/combine/observableobject) that manages URL-based media downloads.
///
/// This downloader persists download metadata in a SwiftData database.
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class URLDownloader<Provider>: ObservableObject where Provider: URLAssetDownloadStoreProvider {
    private let downloadManager: Downloader<URLAssetDownloadStore<Provider>>

    /// Returns existing downloads.
    @Published public private(set) var downloads: [Download] = []

    /// Creates a downloader for URL-based content with custom data.
    ///
    /// - Parameters:
    ///   - name: The name of the database on disk. If an application uses multiple ``URLDownloader`` instances, each
    ///     one should use a different name.
    ///   - storeProviderType: The store provider type.
    ///   - configuration: A configuration object that defines the behavior and policies of the URL session used to
    ///     perform file transfers.
    public init(
        name: String? = nil,
        storeProviderType: Provider.Type,
        configuration: URLSessionConfiguration
    ) throws {
        let downloader = Downloader(configuration: configuration, store: try URLAssetDownloadStore(name: name, providerType: storeProviderType))
        self.downloadManager = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    /// Adds a download for the given URL and metadata.
    ///
    /// - Parameters:
    ///   - url: The URL of the content to download.
    ///   - metadata: The metadata associated with the content.
    ///   - configuration: The download configuration.
    /// - Returns: A download associated with the given URL. If a download already exists for the URL, the existing
    ///   download is returned instead.
    @discardableResult
    public func addDownload(url: URL, metadata: AssetMetadata<Provider.CustomData>, configuration: DownloadConfiguration = .default) -> Download {
        downloadManager.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    /// Returns the download matching the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the content.
    ///   - metadata: The metadata associated with the content.
    public func download(matching url: URL, metadata: AssetMetadata<Provider.CustomData>) -> Download? {
        downloadManager.download(matching: .init(url: url, metadata: metadata))
    }

    /// Creates a ``PlayerItem`` from the given download.
    ///
    /// - Parameters:
    ///   - download: The download from which to create the player item.
    ///   - trackerAdapters: The ``TrackerAdapter`` instances to use for tracking playback events.
    /// - Returns: A player item, or `nil` if the download is not playable yet.
    public func playerItem(
        for download: Download,
        trackerAdapters: [TrackerAdapter<AssetMetadata<Provider.CustomData>>] = []
    ) -> PlayerItem? {
        downloadManager.playerItem(for: download, trackerAdapters: trackerAdapters)
    }

    /// Removes the given download.
    ///
    /// - Parameter download: The download to remove.
    ///
    /// Resources associated with the download, including local storage entries and files on disk, are cleaned up automatically.
    public func removeDownload(_ download: Download) {
        downloadManager.removeDownload(download)
    }

    /// Removes all downloads.
    ///
    /// Resources associated with the downloads, including local storage entries and files on disk, are cleaned up automatically.
    public func removeAllDownloads() {
        downloadManager.removeAllDownloads()
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public extension URLDownloader where Provider == URLEmptyAssetProvider {
    /// Creates a downloader for URL-based content without custom data.
    ///
    /// - Parameters:
    ///   - name: The name of the database on disk. If an application uses multiple ``URLDownloader`` instances, each
    ///     one should use a different name.
    ///   - configuration: A configuration object that defines the behavior and policies of the URL session used to
    ///     perform file transfers.
    convenience init(name: String? = nil, configuration: URLSessionConfiguration) throws {
        try self.init(name: name, storeProviderType: URLEmptyAssetProvider.self, configuration: configuration)
    }

    /// Adds a download for the given URL and metadata.
    ///
    /// - Parameters:
    ///   - url: The URL of the content to download.
    ///   - metadata: The metadata associated with the content.
    ///   - configuration: The download configuration.
    /// - Returns: A download associated with the given URL. If a download already exists for the URL, the existing
    ///   download is returned instead.
    @discardableResult
    func addDownload(url: URL, metadata: PlayerMetadata, configuration: DownloadConfiguration = .default) -> Download {
        downloadManager.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    /// Returns the download matching the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the content.
    ///   - metadata: The metadata associated with the content.
    func download(url: URL, metadata: PlayerMetadata) -> Download? {
        downloadManager.download(matching: .init(url: url, metadata: metadata))
    }
}
