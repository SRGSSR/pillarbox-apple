//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation

final class DownloadSessionMock {
    private let delay: TimeInterval

    weak var delegate: (any DownloadSessionDelegate)?

    init(delay: TimeInterval = 0) {
        self.delay = delay
    }
}

extension DownloadSessionMock: DownloadSession {
    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never> {
        guard createIfNeeded else {
            return Empty().eraseToAnyPublisher()
        }
        // TODO: Local network call
        let task = URLSession.shared.downloadTask(with: URLRequest(url: URL(string: "https://httpbin.org/bytes/50")!)) { [weak self] fileUrl, _, error in
            guard let self else { return }
            if let error {
                delegate?.downloadSessionDidFailWithError(error, forId: id)
            }
            else if let fileUrl {
                // TODO: Removal might require moving this file somewhere else
                // See https://developer.apple.com/documentation/foundation/downloading-files-from-websites
                delegate?.downloadSessionWillDownloadToLocation(fileUrl, forId: id)
            }
        }
        task.resume()
        return Just(task)
            .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
