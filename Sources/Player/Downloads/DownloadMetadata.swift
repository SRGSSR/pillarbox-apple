//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadMetadata: Codable {
    let id: String
    let title: String
    let url: URL
    let bookmarkData: Data?
    let hasFailed: Bool
}
