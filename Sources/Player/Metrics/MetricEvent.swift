//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A metric event.
public struct MetricEvent {
    /// A kind of metric event.
    public enum Kind {
        /// Asset loading.
        case assetLoading(DateInterval)

        /// Resource loading.
        case resourceLoading(DateInterval)
    }

    /// The kind of event.
    public let kind: Kind

    /// The date at which the event was created.
    public let date = Date()

    /// The player time.
    ///
    /// Might be `.invalid`.
    public let time: CMTime
}
