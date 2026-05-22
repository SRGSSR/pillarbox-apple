//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import UIKit

#if DEBUG

@available(tvOS, unavailable)
final class DownloadManager<L, S>: NSObject, DownloadManagement<S>, AVAssetDownloadDelegate
where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
    private let store: S

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: (any DownloadSession)!

    @Published private(set) var downloads: [Download] = []

    init(loaderType: L.Type, sessionProvider: DownloadSessionProvider, store: S) {
        self.store = store
        super.init()
        let session = makeSession(using: sessionProvider)
        self.session = session
        self.downloads = store.downloadRecords().map { record in
            Download(loaderType: loaderType, record: record, session: session, store: store)
        }
    }

    @discardableResult
    func add(input: L.Input) -> Download {
        if let download = download(matching: input) {
            return download
        }
        else {
            let download = Download(loaderType: L.self, input: input, session: session, store: store)
            downloads.append(download)
            return download
        }
    }

    func download(matching input: L.Input) -> Download? {
        let id = type(of: store).id(from: input)
        return downloads.first { $0.id == id }
    }

    func playerItem(for download: Download, trackerAdapters: [TrackerAdapter<L.Metadata>]) -> PlayerItem? {
        guard downloads.contains(download) else { return nil }
        return .init(download: download, store: store, trackerAdapters: trackerAdapters)
    }

    func remove(_ download: Download) {
        guard downloads.contains(download) else { return }
        download.remove()
        downloads.removeAll { $0.id == download.id }
    }

    func removeAll() {
        downloads.forEach { download in
            download.remove()
        }
        downloads.removeAll()
    }

    private func makeSession(using sessionProvider: DownloadSessionProvider) -> any DownloadSession {
        switch sessionProvider {
        case let .urlSession(configuration):
            return AVAssetDownloadURLSession(configuration: configuration, assetDownloadDelegate: self, delegateQueue: .main)
        case let .custom(session):
            return session
        }
    }

    // MARK: AVAssetDownloadDelegate

#if os(iOS)
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let download = download(matching: assetDownloadTask) else { return }
        download.attach(to: location)
    }
#endif

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let error, let download = download(matching: task) else { return }
        download.fail(with: error)
    }

    private func download(matching task: URLSessionTask) -> Download? {
        downloads.first { $0.matches(task: task) }
    }
}

#endif
