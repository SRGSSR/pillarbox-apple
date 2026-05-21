//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

protocol DownloadSession {
    func downloadJobPublisher(id: String, asset: Asset, title: String?, lastKnownProgress: Double, createIfNeeded: Bool) -> AnyPublisher<DownloadJob, Never>
}
