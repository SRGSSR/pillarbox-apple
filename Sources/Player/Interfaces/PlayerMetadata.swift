//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// A protocol for custom player metadata integration.
public protocol PlayerMetadata: AnyObject {
    associatedtype Metadata

    /// Creates an instance for holding player metadata.
    init()

    /// A method called when metadata is updated.
    ///
    /// - Parameter metadata: The updated metadata.
    func update(metadata: Metadata)

    /// A method formatting metadata for Control Center display.
    ///
    /// - Parameter error: Error information which could possibly be displayed in the Control Center.
    /// - Returns: A dictionary suitable for display.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter#1674387)
    /// for more information.
    func mediaItemInfo(with error: Error?) -> NowPlayingInfo

    /// A method formatting metadata for display in the standard system player user interface.
    ///
    /// - Returns: An array of metadata items.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/avkit/customizing_the_tvos_playback_experience)
    /// for more information.
    func metadataItems() -> [AVMetadataItem]

    // TODO: `AVNavigationMarkersGroup` should be used but is available on tvOS only. We could maybe extend it to iOS
    //       so that we have a common formalism to handle chapters.
    func navigationMarkerGroups() -> [AVTimedMetadataGroup]
}

public extension PlayerMetadata {
    /// Creates an adapter for the receiver with the provided mapping to its metadata format.
    ///
    /// - Parameter mapper: A closure that maps an item metadata to player metadata.
    /// - Returns: The metadata adapter.
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> MetadataAdapter<M> {
        .init(metadataType: Self.self, mapper: mapper)
    }
}

public extension PlayerMetadata where Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Returns: The metadata adapter.
    ///
    /// This adapter is useful when no metadata is delivered by the item but you still want to implement player
    /// metadata display (mostly static and not related to the item itself).
    static func adapter<M>() -> MetadataAdapter<M> {
        .init(metadataType: Self.self) { _ in }
    }
}
