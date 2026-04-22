//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadMetadata: Codable {
    let id: UUID
    let assetId: String
    let assetLoaderType: AssetLoaderType
    let bookmarkData: Data?
    let hasFailed: Bool
}
