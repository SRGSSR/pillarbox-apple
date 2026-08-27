//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation
import PillarboxAnalytics

@_spi(DownloaderPrivate)
import PillarboxPlayer

/// An observable object that manages URN-based media downloads.
///
/// A downloader is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// used to download media content. This downloader persists download metadata in a SwiftData database.
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class URNDownloader: ObservableObject {
    private let downloader: Downloader<URNAssetDownloadStore>

    /// Returns the existing downloads.
    @Published public private(set) var downloads: [Download] = []

    /// Creates a downloader for URN-based content.
    ///
    /// - Parameters:
    ///   - name: The name of the database on disk. If an application uses multiple ``URNDownloader`` instances, each
    ///     one should use a different name.
    ///   - configuration: A configuration object that defines the behavior and policies of the URL session used to
    ///     perform file transfers.
    public init(name: String? = nil, configuration: URLSessionConfiguration) throws {
        let downloader = Downloader(configuration: configuration, store: try URNAssetDownloadStore(name: name))
        self.downloader = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    /// Adds a download for the given URN.
    ///
    /// - Parameters:
    ///   - urn: The URN of the content to download.
    ///   - server: The server from which to download the content.
    ///   - httpHeaders: The HTTP headers to include when retrieving the content.
    /// - Returns: A download associated with the given URN. If a download already exists for the URN, the existing
    ///   download is returned instead.
    @discardableResult
    public func addDownload(
        urn: String,
        server: Server = .production,
        httpHeaders: [String: String] = [:],
        configuration: DownloadConfiguration = .default
    ) -> Download {
        downloader.addDownload(for: .init(urn: urn, server: server, httpHeaders: httpHeaders), configuration: configuration)
    }

    /// Returns the download matching the given URN.
    ///
    /// - Parameters:
    ///   - urn: The URN identifying the content.
    ///   - server: The server from which the content is downloaded.
    public func download(urn: String, server: Server) -> Download? {
        downloader.download(matching: .init(urn: urn, server: server, httpHeaders: [:]))
    }

    /// Creates a ``PlayerItem`` from the given download.
    ///
    /// - Parameters:
    ///   - download: The download from which to create the player item.
    ///   - commandersActSource: The source of events sent to Commanders Act.
    ///   - trackerAdapters: The ``TrackerAdapter`` instances to use for tracking playback events.
    /// - Returns: A player item, or `nil` if the download is not yet playable.
    ///
    /// In addition to the trackers you provide, playback is tracked according to SRG SSR analytics standards. Tracking
    /// events may be cached while the device is offline and submitted when connectivity is restored.
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

#endif
