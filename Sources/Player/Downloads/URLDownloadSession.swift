//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import AVFoundation
import Combine

@available(tvOS, unavailable)
final class URLDownloadSession: NSObject {
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: AVAssetDownloadURLSession!

    weak var delegate: (any DownloadSessionDelegate)?

    init(configuration: URLSessionConfiguration) {
        super.init()
        session = AVAssetDownloadURLSession(configuration: configuration, assetDownloadDelegate: self, delegateQueue: .main)
    }
}

@available(tvOS, unavailable)
extension URLDownloadSession: DownloadSession {
    func createTask(forId id: String, asset: Asset, metadata: PlayerMetadata) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(asset: asset.urlAsset(), title: metadata.title ?? id)
        configuration.artworkData = metadata.imageSource.data
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    func sessionTaskPublisher(forId id: String) -> AnyPublisher<URLSessionTask?, Never> {
        taskPublisher(forId: id).eraseToAnyPublisher()
    }

    func cancelTasks(forId id: String) {
        session.getAllTasks { tasks in
            tasks.filter { $0.taskDescription == id }.forEach { task in
                task.cancel()
            }
        }
    }

    private func taskPublisher(forId id: String) -> AnyPublisher<URLSessionTask?, Never> {
        Future { [session] promise in
            session.getAllTasks { tasks in
                let task = tasks.first { $0.taskDescription == id }
                promise(.success(task))
            }
        }
        .eraseToAnyPublisher()
    }
}

@available(tvOS, unavailable)
extension URLDownloadSession: AVAssetDownloadDelegate {
#if os(iOS)
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let delegate, let id = assetDownloadTask.taskDescription else { return }
        delegate.downloadSessionTask(assetDownloadTask, willDownloadToLocation: location, forId: id)
    }
#endif

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let delegate, let id = task.taskDescription else { return }
        delegate.downloadSessionTask(task, didCompleteWithError: error, forId: id)
    }
}

#endif
