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

    func sessionTaskPublisher(id: String) -> AnyPublisher<URLSessionTask?, Never>
    func createTask(id: String, asset: Asset, metadata: PlayerMetadata) -> URLSessionTask
}

#endif
