//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension Player {
    /// Returns the current time.
    ///
    /// Returns `.invalid` when the time is unknown.
    func time() -> CMTime {
        properties.time()
    }

    /// Returns the current date.
    ///
    /// The date is `nil` when no date information is available from the stream.
    func date() -> Date? {
        properties.date()
    }
}
