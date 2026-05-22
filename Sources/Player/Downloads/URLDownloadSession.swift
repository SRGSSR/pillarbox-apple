//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

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
    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never> {
        taskPublisher(withDescription: id)
            .compactMap { task in
                if let task {
                    return task
                }
                else if createIfNeeded {
                    return self.createTask(id: id, asset: asset, title: title)
                }
                else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    private func createTask(id: String, asset: Asset, title: String?) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(
            asset: asset.urlAsset(),
            title: title ?? id
        )
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    private func taskPublisher(withDescription description: String) -> AnyPublisher<URLSessionTask?, Never> {
        Future { [session] promise in
            session.getAllTasks { tasks in
                let task = tasks.first { $0.taskDescription == description }
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
        delegate.downloadSessionWillDownloadToLocation(location, forId: id)
    }
#endif

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let delegate, let id = task.taskDescription, let error else { return }
        delegate.downloadSessionDidFailWithError(error, forId: id)
    }
}
