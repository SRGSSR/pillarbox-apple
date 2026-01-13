//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension Player {
    /// The current time.
    ///
    /// Returns `.invalid` when the time is unknown.
    func time() -> CMTime {
        properties.time()
    }

    /// The current date.
    ///
    /// The date is `nil` when no date information is available from the stream.
    func date() -> Date? {
        properties.date()
    }

    func playbackPosition() -> PlaybackPosition {
        .init(time: time(), date: date()) // FIXME: ItemProperties should store the playback position, time & date above should derive from it.
    }
}
