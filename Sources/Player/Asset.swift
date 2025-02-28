//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// An asset representing content to be played.
///
/// Three categories of assets are provided:
///
/// - Simple assets which can be played directly.
/// - Custom assets which require a custom resource loader delegate.
/// - Encrypted assets which require a FairPlay content key session delegate.
public struct Asset<M> {
    let resource: Resource
    let metadata: M
    let configuration: PlaybackConfiguration

    /// Returns a simple asset playable from a URL.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    public static func simple(url: URL, metadata: M, configuration: PlaybackConfiguration = .default) -> Self {
        .init(resource: .simple(url: url), metadata: metadata, configuration: configuration)
    }

    /// Returns an asset loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            resource: .custom(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
        )
    }

    /// Returns an encrypted asset loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    public static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            resource: .encrypted(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
        )
    }

    /// Returns an unavailable asset.
    ///
    /// - Parameters:
    ///   - error: The reason why the asset is not available.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: The asset
    ///
    /// Use an unavailable asset when a business reason prevents the content from being played but metadata is
    /// nonetheless available.
    public static func unavailable(
        with error: Error,
        metadata: M
    ) -> Self {
        .init(
            resource: .failing(error: error),
            metadata: metadata,
            configuration: .default
        )
    }
}

public extension Asset where M == Void {
    /// Returns a simple asset playable from a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    static func simple(
        url: URL,
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            resource: .simple(url: url),
            metadata: (),
            configuration: configuration
        )
    }

    /// Returns an asset loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            resource: .custom(url: url, delegate: delegate),
            metadata: (),
            configuration: configuration
        )
    }

    /// Returns an encrypted asset loaded with a content key session.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The content key session delegate to use.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        configuration: PlaybackConfiguration = .default
    ) -> Self {
        .init(
            resource: .encrypted(url: url, delegate: delegate),
            metadata: (),
            configuration: configuration
        )
    }
}
