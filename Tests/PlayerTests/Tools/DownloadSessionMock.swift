//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

struct HTTPError: Error {}

@available(tvOS, unavailable)
final class DownloadSessionMock: NSObject {
    private let directoryUrl: URL

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var session: URLSession!

    weak var delegate: (any DownloadSessionDelegate)?

    init(name: String) {
        self.directoryUrl = FileManager.default.temporaryDirectory.appendingPathComponent("DownloadSessionMock").appendingPathComponent(name)
        super.init()
        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
        createEmptyDirectory()
    }

    private func createEmptyDirectory() {
        try? FileManager.default.removeItem(at: directoryUrl)
        try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
    }
}

@available(tvOS, unavailable)
extension DownloadSessionMock: DownloadSession {
    func sessionTaskPublisher(id: String) -> AnyPublisher<URLSessionTask?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    func createTask(id: String, asset: Asset, metadata: PlayerMetadata) -> URLSessionTask {
        let task = session.downloadTask(with: asset.urlAsset().url)
        task.taskDescription = id
        task.resume()
        return task
    }
}

@available(tvOS, unavailable)
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
        delegate.downloadSessionDidCompleteWithError(error ?? Self.error(from: task), task: task, forId: id)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let delegate, let id = downloadTask.taskDescription else { return }
        if let error = Self.error(from: downloadTask) {
            delegate.downloadSessionDidCompleteWithError(error, task: downloadTask, forId: id)
        }
        else {
            let destination = directoryUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension(Self.fileExtension(from: downloadTask))
            do {
                try FileManager.default.moveItem(at: location, to: destination)
                delegate.downloadSessionWillDownloadToLocation(destination, task: downloadTask, forId: id)
            } catch {
                delegate.downloadSessionDidCompleteWithError(error, task: downloadTask, forId: id)
            }
        }
    }
}
