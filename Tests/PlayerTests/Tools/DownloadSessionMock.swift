//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

final class DownloadSessionMock: NSObject {
    private let identifier = UUID().uuidString

    private let delay: TimeInterval

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: URLSession!

    weak var delegate: (any DownloadSessionDelegate)?

    init(delay: TimeInterval = 0) {
        self.delay = delay
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
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
        // TODO: Local network call
        let task = session.downloadTask(with: URLRequest(url: URL(string: "https://httpbin.org/bytes/50")!))
        task.taskDescription = id
        task.resume()
        return task
    }
}

extension DownloadSessionMock: URLSessionDownloadDelegate {
    private func location(forId id: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathExtension("\(identifier)-\(id)")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let delegate, let error, let id = task.taskDescription else { return }
        delegate.downloadSessionDidFailWithError(error, forId: id)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let delegate, let id = downloadTask.taskDescription else { return }
        do {
            try FileManager.default.moveItem(at: location, to: self.location(forId: id))
        }
        catch {
            delegate.downloadSessionDidFailWithError(error, forId: id)
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let delegate, let id = downloadTask.taskDescription else { return }
        let location = location(forId: id)
        delegate.downloadSessionWillDownloadToLocation(location, forId: id)
        FileManager.default.createFile(atPath: location.path(), contents: nil)
    }
}
