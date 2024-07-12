//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A metric event.
public struct MetricEvent: Hashable {
    /// A kind of metric event.
    public enum Kind {
        /// Asset loading.
        ///
        /// Measures the time for a ``PlayerItem`` to load its associated asset.
        case assetLoading(DateInterval)

        /// Resource loading.
        ///
        /// Measures the time for the player to load the associated resource until playback is ready to start.
        case resourceLoading(DateInterval)

        /// Failure.
        case failure(Error)

        /// Warning.
        case warning(Error)

        /// Stall.
        case stall

        /// Resume after stall.
        ///
        /// Measures the time for the player to recover after a stall.
        case resumeAfterStall(DateInterval)
    }

    private let id = UUID()

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
        case let .assetLoading(dateInterval):
            return dateInterval.duration
        case let .resourceLoading(dateInterval):
            return dateInterval.duration
        default:
            return 0
        }
    }

    init(kind: Kind, date: Date = .init(), time: CMTime = .invalid) {
        self.kind = kind
        self.date = date
        self.time = time
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MetricEvent: CustomStringConvertible {
    public var description: String {
        switch kind {
        case let .assetLoading(dateInterval):
            return "assetLoading(\(dateInterval.duration))"
        case let .resourceLoading(dateInterval):
            return "resourceLoading(\(dateInterval.duration))"
        case let .failure(error):
            return "failure(\(error.localizedDescription))"
        case let .warning(error):
            return "warning(\(error.localizedDescription))"
        case .stall:
            return "stall"
        case let .resumeAfterStall(dateInterval):
            return "resumeAfterStall(\(dateInterval.duration))"
        }
    }
}
