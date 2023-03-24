//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A type representing empty metadata associated with an asset.
public struct EmptyAssetMetadata: AssetMetadata {
    // Not meant to be instantiated, only exists as a type for function signatures and where clauses.
    private init() {}

    public func nowPlayingMetadata() -> NowPlayingMetadata {
        .init()
    }
}

/// A protocol representing metadata associated with an asset.
public protocol AssetMetadata {
    /// Returns metadata used to display what is currently being played, most notably in the Control Center.
    func nowPlayingMetadata() -> NowPlayingMetadata
}
