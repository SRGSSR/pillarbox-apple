//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

/// An [observable object](https://developer.apple.com/documentation/combine/observableobject) that manages Pillarbox-standard media downloads.
///
/// This downloader persists download metadata in a SwiftData database.
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class StandardDownloader<Provider>: ObservableObject where Provider: StandardAssetDownloadStoreProvider {
    private let downloader: Downloader<StandardAssetDownloadStore<Provider>>

    /// Returns existing downloads.
    @Published public private(set) var downloads: [Download] = []

    /// Creates a downloader for Pillarbox-standard content with custom data.
    ///
    /// - Parameters:
    ///   - name: The name of the database on disk. If an application uses multiple ``StandardDownloader`` instances, each
    ///     one should use a different name.
    ///   - storeProviderType: The store provider type.
    ///   - configuration: A configuration object that defines the behavior and policies of the URL session used to
    ///     perform file transfers.
    public init(
        name: String? = nil,
        storeProviderType: Provider.Type,
        configuration: URLSessionConfiguration
    ) throws {
        self.downloader = Downloader(configuration: configuration, store: try StandardAssetDownloadStore(name: name, providerType: storeProviderType))

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
    public func addDownload(for input: Provider.Input, configuration: DownloadConfiguration = .default) -> Download {
        downloader.addDownload(for: input, configuration: configuration)
    }

    /// Returns the download matching the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the content.
    ///   - metadata: The metadata associated with the content.
    public func download(matching input: Provider.Input) -> Download? {
        downloader.download(matching: input)
    }

    /// Creates a ``PlayerItem`` from the given download.
    ///
    /// - Parameters:
    ///   - download: The download from which to create the player item.
    ///   - trackerAdapters: The ``TrackerAdapter`` instances to use for tracking playback events.
    /// - Returns: A player item, or `nil` if the download is not playable yet.
    public func playerItem(
        for download: Download,
        trackerAdapters: [TrackerAdapter<AssetMetadata<Provider.CustomData?>>] = []
    ) -> PlayerItem? {
        downloader.playerItem(for: download, trackerAdapters: trackerAdapters)
    }

    /// Removes the given download.
    ///
    /// - Parameter download: The download to remove.
    ///
    /// Resources associated with the download, including local storage entries and files on disk, are cleaned up automatically.
    public func removeDownload(_ download: Download) {
        downloader.removeDownload(download)
    }

    /// Removes all downloads.
    ///
    /// Resources associated with the downloads, including local storage entries and files on disk, are cleaned up automatically.
    public func removeAllDownloads() {
        downloader.removeAllDownloads()
    }
}
