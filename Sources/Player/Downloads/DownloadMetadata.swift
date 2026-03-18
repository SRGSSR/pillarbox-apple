//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadMetadata: Codable {
    let identifier: String
    let title: String
    let url: URL
    let bookmarkData: Data?
    let hasFailed: Bool
}

extension DownloadMetadata: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(identifier: identifier, title: title)
    }
}
