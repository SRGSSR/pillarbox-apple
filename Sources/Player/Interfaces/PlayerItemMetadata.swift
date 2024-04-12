//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol for player item metadata.
public protocol PlayerItemMetadata {
    /// Returns metadata globally associated with the item.
    ///
    /// - Returns: An array of metadata items.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/avkit/customizing_the_tvos_playback_experience)
    /// for more information.
    func items() -> [AVMetadataItem]

    /// Returns metadata associated with time ranges of the item.
    ///
    /// - Returns: An array of metadata groups.
    ///
    /// Can be used to return program or music information, for example. You can also simply return the same groups as
    /// for chapters.
    func timedGroups() -> [AVTimedMetadataGroup]

    /// Returns metadata describing how the content is structured and can be navigated.
    ///
    /// - Returns: An array of metadata groups.
    ///
    /// Refer to the [official documentation](https://developer.apple.com/documentation/avfoundation/media_playback/presenting_chapter_markers)
    /// for more information.
    func chapterGroups() -> [AVTimedMetadataGroup]
}

extension PlayerItemMetadata {
    func rawMetadata() -> RawPlayerMetadata {
        .init(items: items(), timedGroups: timedGroups(), chapterGroups: chapterGroups())
    }
}
