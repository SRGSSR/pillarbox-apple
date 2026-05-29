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
    private static func error(from task: URLSessionTask) -> Error? {
        guard let httpResponse = task.response as? HTTPURLResponse else { return nil }
        return httpResponse.statusCode >= 400 ? HTTPError() : nil
    }

    private static func fileExtension(from task: URLSessionTask) -> String {
        // Files need to be saved with a proper extension to be locally playable
        guard let url = task.originalRequest?.url else { return "mp4" }
        return url.pathExtension
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let delegate, let id = task.taskDescription else { return }
        delegate.downloadSessionDidCompleteWithError(error ?? Self.error(from: task), forId: id)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let delegate, let id = downloadTask.taskDescription else { return }
        if let error = Self.error(from: downloadTask) {
            delegate.downloadSessionDidCompleteWithError(error, forId: id)
        }
        else {
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(Self.fileExtension(from: downloadTask))
            do {
                try FileManager.default.moveItem(at: location, to: destination)
                delegate.downloadSessionWillDownloadToLocation(destination, forId: id)
            } catch {
                delegate.downloadSessionDidCompleteWithError(error, forId: id)
            }
        }
    }
}
