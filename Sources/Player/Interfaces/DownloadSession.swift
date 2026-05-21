//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

protocol DownloadSession {
    func downloadSessionTaskPublisher(id: String, asset: Asset, title: String?, createIfNeeded: Bool) -> AnyPublisher<DownloadSessionTask, Never>
}
