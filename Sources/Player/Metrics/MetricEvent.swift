//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

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
        case resumeAfterStall
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

extension MetricEvent.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .assetLoading(dateInterval):
            return "Asset loaded in \(Self.duration(from: dateInterval.duration))"
        case let .resourceLoading(dateInterval):
            return "Resource loaded in \(Self.duration(from: dateInterval.duration))"
        case let .failure(error):
            return "[FAILURE] \(error.localizedDescription)"
        case let .warning(error):
            return "[WARNING] \(error.localizedDescription)"
        case .stall:
            return "Stall"
        case let .resumeAfterStall(dateInterval):
            return "Resume after stall for \(Self.duration(from: dateInterval.duration))"
        }
    }

    private static func duration(from interval: TimeInterval) -> String {
        String(format: "%.3fs", interval)
    }
}

extension MetricEvent: CustomStringConvertible {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }

    public var description: String {
        if let duration = Self.duration(from: time) {
            "[\(duration)] \(formattedDate) - \(kind.description)"
        }
        else {
            "\(formattedDate) - \(kind.description)"
        }
    }

    private static func duration(from time: CMTime) -> String? {
        guard time.isValid else { return nil }
        return durationFormatter.string(from: time.seconds)
    }
}
