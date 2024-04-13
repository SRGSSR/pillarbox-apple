//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for metadata associated with an asset.
public protocol AssetMetadata {
    /// Returns metadata related to the associated item.
    var itemMetadata: ItemMetadata { get }

    /// Returns metadata describing how the content is structured and can be navigated.
    var chaptersMetadata: [ChapterMetadata] { get }
}

extension AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(item: itemMetadata, chapters: chaptersMetadata)
    }
}
