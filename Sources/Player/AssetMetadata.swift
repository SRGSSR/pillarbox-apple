//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public protocol AssetMetadata {
    func nowPlayingMetadata() -> NowPlayingMetadata
}

public struct EmptyAssetMetadata: AssetMetadata {
    // Not meant to be instantiated, only exists as a type for function signatures and where clauses.
    private init() {}

    public func nowPlayingMetadata() -> NowPlayingMetadata {
        .init()
    }
}
