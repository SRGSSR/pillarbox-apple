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
final class DownloadManager<L, S>: NSObject, AVAssetDownloadDelegate where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
    private let store: S

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: AVAssetDownloadURLSession!

    @Published private(set) var downloads: [Download<L, S>] = []

    init(loaderType: L.Type, configuration: URLSessionConfiguration, store: S) {
        self.store = store
        super.init()
        self.session = .init(configuration: configuration, assetDownloadDelegate: self, delegateQueue: .main)
        self.downloads = store.downloadRecords().map { record in
            let id = S.identifier(for: record.input)
            return Download(id: id, loaderType: loaderType, record: record, session: session, store: store)
        }
    }

    @discardableResult
    func add(input: S.Input) -> Download<L, S> {
        let id = S.identifier(for: input)
        if let download = downloads.first(where: { $0.id == id }) {
            return download
        }
        else {
            let download = Download(id: id, loaderType: L.self, input: input, session: session, store: store)
            downloads.append(download)
            return download
        }
    }

    func remove(_ download: Download<L, S>) {
        download.cancel()
        downloads.removeAll { $0.id == download.id }
    }

    func removeAll() {
        downloads.forEach { download in
            download.cancel()
        }
        downloads.removeAll()
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

    private func download(matching task: URLSessionTask) -> Download<L, S>? {
        downloads.first { $0.matches(task: task) }
    }
}

#endif
