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
    let configuration: (AVPlayerItem) -> Void

    /// Returns a simple asset playable from a URL.
    /// 
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func simple(url: URL, metadata: M, configuration: @escaping (AVPlayerItem) -> Void = { _ in }) -> Self {
        .init(resource: .simple(url: url), metadata: metadata, configuration: configuration)
    }

    /// Returns an asset loaded with custom resource loading.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - delegate: The custom resource loader to use.
    ///   - metadata: The metadata associated with the asset.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    public static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        metadata: M,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
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
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    public static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        metadata: M,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            resource: .encrypted(url: url, delegate: delegate),
            metadata: metadata,
            configuration: configuration
        )
    }
}

public extension Asset where M == Void {
    /// Returns a simple asset playable from a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    static func simple(
        url: URL,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
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
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    ///
    /// The scheme of the URL to be played has to be recognized by the associated resource loader delegate.
    static func custom(
        url: URL,
        delegate: AVAssetResourceLoaderDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
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
    ///   - configuration: A closure to configure player items created from the receiver.
    /// - Returns: The asset.
    static func encrypted(
        url: URL,
        delegate: AVContentKeySessionDelegate,
        configuration: @escaping (AVPlayerItem) -> Void = { _ in }
    ) -> Self {
        .init(
            resource: .encrypted(url: url, delegate: delegate),
            metadata: (),
            configuration: configuration
        )
    }
}
