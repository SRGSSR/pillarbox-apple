//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation

@available(tvOS, unavailable)
protocol DownloadSession: AnyObject {
    var delegate: DownloadSessionDelegate? { get set }

    func createTask(forId: String, asset: Asset, metadata: PlayerMetadata) -> URLSessionTask
    func sessionTaskPublisher(forId id: String) -> AnyPublisher<URLSessionTask?, Never>

    func cancelTasks(forId id: String)
}

#endif
