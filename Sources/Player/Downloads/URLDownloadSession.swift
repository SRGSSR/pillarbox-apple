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

    // Store locations separately. If a location was created but not associated with a download, we still need to be able
    // to properly clean associated downloaded data.
    private var locations: [Int: URL] = [:]

    weak var delegate: (any DownloadSessionDelegate)?

    init(configuration: URLSessionConfiguration) {
        super.init()
        session = AVAssetDownloadURLSession(configuration: configuration, assetDownloadDelegate: self, delegateQueue: .main)
    }
}

@available(tvOS, unavailable)
extension URLDownloadSession: DownloadSession {
    func taskPublisher(forId id: String, asset: Asset, metadata: PlayerMetadata) -> AnyPublisher<URLSessionTask, Never> {
        Future { promise in
            // Cancel existing tasks first. This avoids:
            //   - Dangling tasks that would still download duplicates of the same content in the background.
            //   - Immediate `willDownloadTo` delegate method call during task creation, which can lead to subtle ordering issues.
            self.tasks(matchingDescription: id) { tasks in
                tasks.forEach { task in
                    task.cancel()
                }
                promise(.success(self.createTask(forId: id, asset: asset, metadata: metadata)))
            }
        }
        .eraseToAnyPublisher()
    }

    func taskPublisher(matchingId id: String) -> AnyPublisher<URLSessionTask?, Never> {
        Future { promise in
            self.tasks(matchingDescription: id) { tasks in
                promise(.success(tasks.first))
            }
        }
        .eraseToAnyPublisher()
    }

    func cancelTasks(matchingId id: String) {
        tasks(matchingDescription: id) { tasks in
            tasks.forEach { task in
                task.cancel()
            }
        }
    }

    private func createTask(forId id: String, asset: Asset, metadata: PlayerMetadata) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(asset: asset.urlAsset(), title: metadata.title ?? id)
        configuration.artworkData = metadata.imageSource.data
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    private func tasks(matchingDescription description: String, completionHandler: @escaping @Sendable ([URLSessionTask]) -> Void) {
        session.getAllTasks { tasks in
            completionHandler(tasks.filter { $0.taskDescription == description })
        }
    }
}

@available(tvOS, unavailable)
extension URLDownloadSession: AVAssetDownloadDelegate {
#if os(iOS)
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
        guard let id = assetDownloadTask.taskDescription else { return }
        locations[assetDownloadTask.taskIdentifier] = location
        delegate?.downloadSessionTask(assetDownloadTask, willDownloadToLocation: location, forId: id)
    }
#endif

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let id = task.taskDescription else { return }
        if error != nil, let location = locations[task.taskIdentifier] {
            removeFile(at: location)
        }
        locations[task.taskIdentifier] = nil
        delegate?.downloadSessionTask(task, didCompleteWithError: error, forId: id)
    }

    private func removeFile(at location: URL) {
        Task {
            do {
                try FileManager.default.removeItem(at: location)
            }
            catch {
                // The location is not always immediately removable when the task completes. Insert a second attempt after
                // a while if this failed the first time.
                try? await Task.sleep(for: .seconds(2))
                try? FileManager.default.removeItem(at: location)
            }
        }
    }
}

#endif
