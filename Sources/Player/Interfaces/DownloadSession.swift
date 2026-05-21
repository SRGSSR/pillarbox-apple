//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

protocol DownloadSession {
    func downloadSessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<DownloadSessionTask, Never>
}

extension DownloadSession {
    func downloadSourcePublisher(
        id: String,
        asset: Asset,
        title: String?,
        createTaskIfNeeded: Bool,
        progressEstimate: Double
    ) -> AnyPublisher<DownloadSource, Never> {
        downloadSessionTaskPublisher(id: id, asset: asset, title: title, createIfNeeded: createTaskIfNeeded)
            .map { .task($0) }
            .prepend(.estimate(progressEstimate))
            .eraseToAnyPublisher()
    }
}
