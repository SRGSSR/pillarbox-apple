//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class URLDownloader<CustomData: Codable>: ObservableObject {
    private let downloader: Downloader<URLAssetDownloadStore<CustomData>>

    @Published public private(set) var downloads: [Download] = []

    public init(name: String? = nil, customDataType: CustomData.Type = EmptyCustomData.self, configuration: URLSessionConfiguration) throws {
        let downloader = Downloader(configuration: configuration, store: try URLAssetDownloadStore<CustomData>(name: name))
        self.downloader = downloader

        downloader.$downloads
            .assign(to: &$downloads)
    }

    @discardableResult
    public func addDownload(url: URL, metadata: AssetMetadata<CustomData>, configuration: DownloadConfiguration = .default) -> Download {
        downloader.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    public func download(url: URL, metadata: AssetMetadata<CustomData>) -> Download? {
        downloader.download(matching: .init(url: url, metadata: metadata))
    }

    public func playerItem(
        for download: Download,
        trackerAdapters: [TrackerAdapter<AssetMetadata<CustomData>>] = []
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
public extension URLDownloader where CustomData == EmptyCustomData {
    @discardableResult
    func addDownload(url: URL, metadata: PlayerMetadata, configuration: DownloadConfiguration = .default) -> Download {
        downloader.addDownload(for: .init(url: url, metadata: metadata), configuration: configuration)
    }

    func download(url: URL, metadata: PlayerMetadata) -> Download? {
        downloader.download(matching: .init(url: url, metadata: metadata))
    }
}

#endif

// swiftlint:enable missing_docs
