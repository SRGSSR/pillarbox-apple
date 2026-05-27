//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

struct HTTPError: Error {}

final class DownloadSessionMock: NSObject {
    private let delay: TimeInterval
    private var destinations: [String: URL] = [:]

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
    private static func error(from downloadTask: URLSessionDownloadTask) -> Error? {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else { return nil }
        return httpResponse.statusCode >= 400 ? HTTPError() : nil
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let delegate, let error, let id = task.taskDescription else { return }
        delegate.downloadSessionDidFailWithError(error, forId: id)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let delegate, let id = downloadTask.taskDescription else {
            return
        }
        if let error = Self.error(from: downloadTask) {
            delegate.downloadSessionDidFailWithError(error, forId: id)
        }
        else if let destination = destinations[id] {
            do {
                try FileManager.default.replaceItem(at: destination, withItemAt: location, backupItemName: nil, resultingItemURL: nil)
            }
            catch {
                delegate.downloadSessionDidFailWithError(error, forId: id)
            }
        }
        destinations[id] = nil
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let delegate, let id = downloadTask.taskDescription, Self.error(from: downloadTask) == nil else {
            return
        }
        // Creates a dummy file when the first chunk is received to approximate the behavior of `AVAssetDownloadURLSession`.
        if bytesWritten == totalBytesWritten {
            let destination = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            destinations[id] = destination
            delegate.downloadSessionWillDownloadToLocation(destination, forId: id)
            FileManager.default.createFile(atPath: destination.path(), contents: nil)
        }
    }
}
