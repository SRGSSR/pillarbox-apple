//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVAssetDownloadURLSession: DownloadSession {
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
}

private extension AVAssetDownloadURLSession {
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
