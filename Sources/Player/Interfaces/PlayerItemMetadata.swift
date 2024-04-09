//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for player item metadata integration.
// TODO: Remove adapter, use protocol as direct recipe for conversion
public protocol PlayerItemMetadata {
    /// A type describing the configuration offered for metadata display.
    ///
    /// Use `Void` if no such configuration is offered.
    associatedtype Configuration

    /// A type describing how metadata is stored internally.
    ///
    /// Use `Void` if no metadata is required. In such cases metadata can still be displayed by the player but in
    /// a way that is not associated with any item.
    associatedtype Metadata

    /// Creates an instance for holding metadata and formatting it for display by the player.
    ///
    /// - Parameter configuration: The metadata configuration.
    init(configuration: Configuration)

    /// Returns metadata globally associated with the item.
    ///
    /// - Returns: An array of metadata items.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/avkit/customizing_the_tvos_playback_experience)
    /// for more information.
    func items(from metadata: Metadata) -> [AVMetadataItem]

    /// Returns metadata associated with time ranges of the item.
    ///
    /// - Returns: An array of metadata groups.
    ///
    /// Can be used to return program or music information, for example. You can also simply the same groups as
    /// for chapters.
    func timedGroups(from metadata: Metadata) -> [AVTimedMetadataGroup]

    /// Returns metadata describing how the content is structured and how it can be navigated.
    ///
    /// - Returns: An array of metadata groups.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/media_playback/presenting_chapter_markers)
    /// for more information.
    func chapterGroups(from metadata: Metadata) -> [AVTimedMetadataGroup]
}

public extension PlayerItemMetadata {
    /// Creates an adapter for the receiver with the provided mapping to its metadata format.
    ///
    /// - Parameters:
    ///   - configuration: The metadata configuration.
    ///   - mapper: A closure that maps an item metadata to player metadata.
    /// - Returns: The metadata adapter.
    static func adapter<M>(configuration: Configuration, mapper: @escaping (M) -> Metadata) -> MetadataAdapter<M> {
        .init(metadataType: Self.self, configuration: configuration, mapper: mapper)
    }
}

public extension PlayerItemMetadata where Configuration == Void {
    /// Creates an adapter for the receiver with the provided mapping to its metadata format.
    ///
    /// - Parameter mapper: A closure that maps an item metadata to player metadata.
    /// - Returns: The metadata adapter.
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> MetadataAdapter<M> {
        .init(metadataType: Self.self, configuration: (), mapper: mapper)
    }
}

public extension PlayerItemMetadata where Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Returns: The metadata adapter.
    ///
    /// This adapter is useful when no metadata is delivered by the item but you still want to implement player
    /// metadata display (mostly static and not related to the item itself).
    static func adapter<M>(configuration: Configuration) -> MetadataAdapter<M> {
        .init(metadataType: Self.self, configuration: configuration) { _ in }
    }
}

public extension PlayerItemMetadata where Configuration == Void, Metadata == Void {
    /// Creates an adapter for the receiver.
    ///
    /// - Returns: The metadata adapter.
    ///
    /// This adapter is useful when no metadata is delivered by the item but you still want to implement player
    /// metadata display (mostly static and not related to the item itself).
    static func adapter<M>() -> MetadataAdapter<M> {
        .init(metadataType: Self.self, configuration: ()) { _ in }
    }
}
