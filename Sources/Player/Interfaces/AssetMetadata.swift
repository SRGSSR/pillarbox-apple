//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol representing metadata associated with an ``Asset``.
public protocol AssetMetadata {
    /// Returns metadata used to display what is currently being played.
    ///
    /// This metadata is most notably displayed in the Control Center.
    func nowPlayingMetadata() -> NowPlayingMetadata
}

/// An extension providing a default implementation for the `nowPlayingMetadata()` method.
public extension AssetMetadata {
    /// Returns a `NowPlayingMetadata` instance with default values.
    func nowPlayingMetadata() -> NowPlayingMetadata {
        .init()
    }
}

extension Never: AssetMetadata {}
