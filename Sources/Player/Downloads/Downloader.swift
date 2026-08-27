//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation

/// An observable object that manages media downloads.
///
/// A downloader is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// used to download media content. Each downloader is associated with a single store. The store defines:
///
/// - How metadata is loaded, through its ``AssetDownloadStore/Loader`` associated type.
/// - How metadata associated with downloads is persisted.
@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public final class Downloader<S>: ObservableObject where S: AssetDownloadStore {
    private let store: S
    private let session: any DownloadSession

    /// Returns the existing downloads.
    @Published public private(set) var downloads: [Download]

    init(store: S, session: some DownloadSession) {
        self.store = store
        self.session = session
        self.downloads = store.downloadRecords().map { record in
            Download(record: record, session: session, store: store)
        }
        session.delegate = self
    }

    /// Creates a downloader that persists its downloads to a store.
    ///
    /// - Parameters:
    ///   - configuration: A configuration object that defines the behavior and policies of the URL session used to
    ///     perform file transfers.
    ///   - store: The store used to persist downloads.
    public convenience init(configuration: URLSessionConfiguration, store: S) {
        self.init(store: store, session: URLDownloadSession(configuration: configuration))
    }

    /// Creates a download for the given input.
    ///
    /// - Parameter input: The input required to perform the download.
    /// - Returns: A download associated with the given input. If a download already exists for the input, the existing
    ///   download is returned instead.
    @discardableResult
    public func addDownload(for input: S.Loader.Input, configuration: DownloadConfiguration = .default) -> Download {
        if let download = download(matching: input) {
            return download
        }
        else {
            let download = Download(input: input, configuration: configuration, session: session, store: store)
            downloads.append(download)
            return download
        }
    }

    /// Returns the download matching the given input.
    ///
    /// - Parameter input: The input that identifies the download.
    /// - Returns: The matching download, if one exists.
    public func download(matching input: S.Loader.Input) -> Download? {
        download(matchingId: type(of: store).id(from: input))
    }

    /// Creates a playable ``PlayerItem`` from the given download.
    ///
    /// - Parameters:
    ///   - download: The download from which to create the player item.
    ///   - trackerAdapters: The ``TrackerAdapter`` instances to use for tracking playback events.
    /// - Returns: A player item, or `nil` if the download is not yet playable.
    public func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<AssetMetadata<S.CustomData>>] = []) -> PlayerItem? {
        guard downloads.contains(download), let record = store.downloadRecord(forId: download.id),
              let metadata = record.metadata, let fileUrl = download.fileUrl else {
            return nil
        }
        let asset = S.asset(fileUrl: fileUrl, customData: metadata.customData)
        return .init(
            assetLoaderType: CustomDirectAssetLoader.self,
            input: .init(asset: asset, metadata: metadata),
            trackerAdapters: trackerAdapters
        )
    }

    /// Removes the given download.
    ///
    /// - Parameter download: The download to remove.
    ///
    /// Resources associated with the download, including local storage entries and files on disk, are cleaned up automatically.
    public func removeDownload(_ download: Download) {
        guard downloads.contains(download) else { return }
        download.remove()
        downloads.removeAll { $0.id == download.id }
    }

    /// Removes all downloads.
    ///
    /// Resources associated with the downloads, including local storage entries and files on disk, are cleaned up automatically.
    public func removeAllDownloads() {
        downloads.forEach { download in
            download.remove()
        }
        downloads.removeAll()
    }

    private func download(matchingId id: String) -> Download? {
        downloads.first { $0.id == id }
    }
}

@available(tvOS, unavailable)
extension Downloader: DownloadSessionDelegate {
    func downloadSessionTask(_ task: URLSessionTask, willDownloadToLocation location: URL, forId id: String) {
        task.attach(to: location)
    }

    func downloadSessionTask(_ task: URLSessionTask, didCompleteWithError error: (any Error)?, forId id: String) {
        guard let error else { return }
        task.fail(with: error)
    }
}

#endif
