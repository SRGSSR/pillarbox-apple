//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol associating metadata with an asset.
public protocol AssetMetadata {
    /// Returns associated player metadata.
    var playerMetadata: PlayerMetadata { get }
}
