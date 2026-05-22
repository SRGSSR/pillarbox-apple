//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

final class DownloadSessionMock: DownloadSession {
    private let isActive: Bool
    private let delay: TimeInterval

    init(isActive: Bool = true, delay: TimeInterval = 0) {
        self.isActive = isActive
        self.delay = delay
    }

    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never> {
        guard isActive else {
            return Empty().eraseToAnyPublisher()
        }
        // TODO: Local network call
        let task = URLSession.shared.downloadTask(with: URLRequest(url: URL(string: "https://httpbin.org/bytes/50")!))
        task.resume()
        return Just(task)
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
