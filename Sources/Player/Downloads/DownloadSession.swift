//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

@available(tvOS, unavailable)
protocol DownloadSession: AnyObject {
    var delegate: DownloadSessionDelegate? { get set }

    func sessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<URLSessionTask, Never>
}

@available(tvOS, unavailable)
extension DownloadSession {
    private static func downloadSessionTaskPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTaskProperties, Never> {
        Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map(DownloadSessionTaskProperties.init)
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
            .map(Self.downloadSessionTaskPublisher)
            .switchToLatest()
            .map { .task($0) }
            .prepend(.estimate(progressEstimate))
            .eraseToAnyPublisher()
    }
}
