//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

protocol DownloadSession {
    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never>
}

extension DownloadSession {
    private static func downloadSessionTaskPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTask, Never> {
        Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map { .init(task: $0, state: $1, progress: $2) }
        .eraseToAnyPublisher()
    }

    func downloadSourcePublisher(
        id: String,
        asset: Asset,
        title: String?,
        createTaskIfNeeded: Bool,
        progressEstimate: Double
    ) -> AnyPublisher<DownloadSource, Never> {
        sessionTaskPublisher(id: id, asset: asset, title: title, createIfNeeded: createTaskIfNeeded)
            .map { Self.downloadSessionTaskPublisher(for: $0) }
            .switchToLatest()
            .map { .task($0) }
            .prepend(.estimate(progressEstimate))
            .eraseToAnyPublisher()
    }
}
