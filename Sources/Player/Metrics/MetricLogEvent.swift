//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A metric log event.
public struct MetricLogEvent {
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
    public let date: Date

    /// The player time.
    ///
    /// Might be `.invalid`.
    public let time: CMTime

    /// The event duration.
    public var duration: TimeInterval {
        switch kind {
        case .assetLoading(let dateInterval):
            return dateInterval.duration
        case .resourceLoading(let dateInterval):
            return dateInterval.duration
        }
    }

    init(kind: Kind, date: Date = .init(), time: CMTime = .invalid) {
        self.kind = kind
        self.date = date
        self.time = time
    }
}
