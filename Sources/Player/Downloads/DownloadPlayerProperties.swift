//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadPlayerProperties {
    static let empty = Self(metadata: .empty, taskProperties: nil, location: nil, error: nil)

    let metadata: PlayerMetadata
    let taskProperties: TaskProperties?
    let location: URL?
    let error: Error?
}
