//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for player metadata formatting.
public protocol PlayerMetadataFormatter {
    /// The type of the metadata to extract information from.
    associatedtype Metadata

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

    /// Returns metadata describing how the content is structured and can be navigated.
    ///
    /// - Returns: An array of metadata groups.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/media_playback/presenting_chapter_markers)
    /// for more information.
    func chapterGroups(from metadata: Metadata) -> [AVTimedMetadataGroup]
}

extension PlayerMetadataFormatter {
    func metadata(from metadata: Metadata) -> RawPlayerMetadata {
        .init(
            items: items(from: metadata),
            timedGroups: timedGroups(from: metadata),
            chapterGroups: chapterGroups(from: metadata)
        )
    }
}
