//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

// swiftlint:disable missing_docs

import Combine
import Foundation
import UIKit

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public final class Downloader<S>: ObservableObject where S: AssetDownloadStore {
    private let store: S
    private let session: any DownloadSession

    @Published public private(set) var downloads: [Download]

    init(store: S, session: some DownloadSession) {
        self.store = store
        self.session = session
        self.downloads = Self.downloads(store: store, session: session)
        session.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    public convenience init(configuration: URLSessionConfiguration, store: S) {
        self.init(store: store, session: URLDownloadSession(configuration: configuration))
    }

    private static func downloads(store: S, session: DownloadSession) -> [Download] {
        store.downloadRecords().map { record in
            Download(record: record, session: session, store: store)
        }
    }

    @discardableResult
    public func addDownload(for input: S.Loader.Input) -> Download {
        if let download = download(matching: input) {
            return download
        }
        else {
            let download = Download(input: input, session: session, store: store)
            downloads.append(download)
            return download
        }
    }

    public func download(matching input: S.Loader.Input) -> Download? {
        download(matchingId: type(of: store).id(from: input))
    }

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

    public func removeDownload(_ download: Download) {
        guard downloads.contains(download) else { return }
        download.remove()
        downloads.removeAll { $0.id == download.id }
    }

    public func removeAllDownloads() {
        downloads.forEach { download in
            download.remove()
        }
        downloads.removeAll()
    }

    private func download(matchingId id: String) -> Download? {
        downloads.first { $0.id == id }
    }

    @objc
    private func didBecomeActive(_ notification: Notification) {
        downloads = Self.downloads(store: store, session: session)
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

// swiftlint:enable missing_docs

#endif
