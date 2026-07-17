//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation

@available(tvOS, unavailable)
final class DownloadManager<L, S>: DownloadManagement<S> where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
    private let store: S
    private let session: any DownloadSession

    @Published private(set) var downloads: [Download]

    init(assetLoaderType: L.Type, store: S, session: some DownloadSession) {
        self.store = store
        self.session = session
        self.downloads = store.downloadRecords().map { record in
            Download(assetLoaderType: assetLoaderType, record: record, session: session, store: store)
        }
        session.delegate = self
    }

    @discardableResult
    func addDownload(for input: S.Loader.Input) -> Download {
        if let download = download(matching: input) {
            return download
        }
        else {
            let download = Download(assetLoaderType: L.self, input: input, session: session, store: store)
            downloads.append(download)
            return download
        }
    }

    func download(matching input: S.Loader.Input) -> Download? {
        download(matchingId: type(of: store).id(from: input))
    }

    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<AssetMetadata<S.CustomData>>]) -> PlayerItem? {
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

    func removeDownload(_ download: Download) {
        guard downloads.contains(download) else { return }
        download.remove()
        downloads.removeAll { $0.id == download.id }
    }

    func removeAllDownloads() {
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
extension DownloadManager: DownloadSessionDelegate {
    func downloadSessionTask(_ task: URLSessionTask, willDownloadToLocation location: URL, forId id: String) {
        task.attach(to: location)
    }

    func downloadSessionTask(_ task: URLSessionTask, didCompleteWithError error: (any Error)?, forId id: String) {
        guard let error else { return }
        task.fail(with: error)
    }
}

#endif
