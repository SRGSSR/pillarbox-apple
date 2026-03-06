//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// TODO: Should check metadata when deserializing. If file does not exist, drop (failable initializer?)

struct DownloadMetadata: Codable {
    let id: String
    let title: String
    let bookmarkData: Data
}
