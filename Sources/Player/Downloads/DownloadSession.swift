//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import AVFoundation
import Combine

@available(tvOS, unavailable)
protocol DownloadSession: AnyObject {
    var delegate: DownloadSessionDelegate? { get set }

    func sessionTaskPublisher(id: String) -> AnyPublisher<URLSessionTask?, Never>
    func createTask(id: String, asset: Asset, metadata: PlayerMetadata) -> URLSessionTask
}

@available(tvOS, unavailable)
extension DownloadSession {
    func downloadSessionTaskPropertiesPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTaskProperties, Never> {
        Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map(DownloadSessionTaskProperties.init)
        .eraseToAnyPublisher()
    }

    func downloadSourceTaskPublisher<CustomData>(
        for task: URLSessionTask?,
        using properties: DownloadProperties<CustomData>
    ) -> AnyPublisher<DownloadSourceKind, Never> {
        guard let task else { return Just(.estimate(properties.progress)).eraseToAnyPublisher() }
        return downloadSessionTaskPropertiesPublisher(for: task)
            .map { .task($0) }
            .eraseToAnyPublisher()
    }
}

#endif
