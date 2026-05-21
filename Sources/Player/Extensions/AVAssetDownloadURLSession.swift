//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVAssetDownloadURLSession: DownloadSession {
    func downloadSessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<DownloadSessionTask, Never> {
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
            .map { Self.downloadSessionTaskPublisher(for: $0) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

private extension AVAssetDownloadURLSession {
    static func downloadSessionTaskPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTask, Never> {
        Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map { .init(task: $0, state: $1, progress: $2) }
        .eraseToAnyPublisher()
    }

    func createTask(id: String, asset: Asset, title: String?) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(
            asset: asset.urlAsset(),
            title: title ?? id
        )
        let task = makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    func taskPublisher(withDescription description: String) -> AnyPublisher<URLSessionTask?, Never> {
        Future { promise in
            self.getAllTasks { tasks in
                let task = tasks.first { $0.taskDescription == description }
                promise(.success(task))
            }
        }
        .eraseToAnyPublisher()
    }
}
