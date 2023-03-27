//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A protocol representing metadata associated with an asset.
public protocol AssetMetadata {
    /// Returns metadata used to display what is currently being played, most notably in the Control Center.
    func nowPlayingMetadata() -> NowPlayingMetadata
}

/// An extension to provide a default implementation for the `nowPlayingMetadata()` method.
public extension AssetMetadata {
    /// Returns an instance of `NowPlayingMetadata` with default values.
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init()
    }
}

/// An extension to conform the `Never` type to `AssetMetadata` protocol.
extension Never: AssetMetadata {}
