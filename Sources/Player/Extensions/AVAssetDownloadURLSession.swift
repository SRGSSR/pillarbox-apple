//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVAssetDownloadURLSession {
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
