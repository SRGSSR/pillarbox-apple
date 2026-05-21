//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

final class DownloadSessionMock: DownloadSession {
    private let delay: TimeInterval

    init(delay: TimeInterval = 0) {
        self.delay = delay
    }

    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never> {
        let task = URLSession.shared.downloadTask(with: URLRequest(url: URL(string: "https://httpbin.org/bytes/50")!))
        task.resume()
        return Just(task)
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
