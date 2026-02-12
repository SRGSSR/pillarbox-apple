//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public final class AssetDownload: ObservableObject {
    public let metadata: PlayerMetadata
    public let fileUrl: URL

    @Published public private(set) var progress: Float?

    // TODO: Should also have download size (can be extracted from Progress)

    init(metadata: PlayerMetadata, fileUrl: URL) {
        self.metadata = metadata
        self.fileUrl = fileUrl
    }
}
