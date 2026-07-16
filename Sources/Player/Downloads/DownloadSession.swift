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

    func taskPublisher(forId id: String, asset: Asset, metadata: PlayerMetadata) -> AnyPublisher<URLSessionTask, Never>
    func taskPublisher(matchingId id: String) -> AnyPublisher<URLSessionTask?, Never>

    func cancelTasks(matchingId id: String)
}

#endif
