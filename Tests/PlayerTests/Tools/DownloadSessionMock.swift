//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

final class DownloadSessionMock: NSObject {
    private let delay: TimeInterval

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: URLSession!

    weak var delegate: (any DownloadSessionDelegate)?

    init(delay: TimeInterval = 0) {
        self.delay = delay
        super.init()
        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
    }
}

extension DownloadSessionMock: DownloadSession {
    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never> {
        guard createIfNeeded else {
            return Empty().eraseToAnyPublisher()
        }
        return Just(sessionTask(id: id, asset: asset, title: title, createIfNeeded: createIfNeeded))
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func sessionTask(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> URLSessionTask {
        let task = session.downloadTask(with: asset.urlAsset().url)
        task.taskDescription = id
        task.resume()
        return task
    }
}

extension DownloadSessionMock: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let delegate, let error, let id = task.taskDescription else { return }
        delegate.downloadSessionDidFailWithError(error, forId: id)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let delegate, let id = downloadTask.taskDescription else { return }
        let location = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        delegate.downloadSessionWillDownloadToLocation(location, forId: id)
        FileManager.default.createFile(atPath: location.path(), contents: nil)
    }
}
