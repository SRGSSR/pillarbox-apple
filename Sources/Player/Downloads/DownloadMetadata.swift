//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadMetadata: Codable, AssetMetadata {
    let id: UUID
    let playerMetadata: PlayerMetadata
    let url: URL?
    let bookmarkData: Data?
    let hasFailed: Bool
}
