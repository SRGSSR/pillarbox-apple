//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public class PlayerItem: AVPlayerItem {
    private let resourceLoaderDelegate: AssetResourceLoaderDelegate

    // swiftlint:disable discouraged_optional_collection

    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    ///   - environment: The environment which the URN is played from.
    public init(urn: String, automaticallyLoadedAssetKeys keys: [String]? = nil, environment: Environment = .production) {
        resourceLoaderDelegate = AssetResourceLoaderDelegate(environment: environment)
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global(qos: .userInitiated))
        super.init(asset: asset, automaticallyLoadedAssetKeys: keys)
        preventLivestreamDelayedPlayback()
    }

    // swiftlint:enable discouraged_optional_collection

    /// Limit buffering and force the player to return to the live edge when re-buffering. This ensures livestreams
    /// cannot be paused and resumed in the past, as requested by business people.
    ///
    /// Remark: These settings do not negatively affect on-demand or DVR livestream playback.
    private func preventLivestreamDelayedPlayback() {
        automaticallyPreservesTimeOffsetFromLive = true
        preferredForwardBufferDuration = 1
    }
}
