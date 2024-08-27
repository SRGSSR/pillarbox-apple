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
        /// Metadata is available.
        ///
        /// The date interval corresponding to the process is provided as associated value. Note that this interval
        /// measures the perceived user experience and might be empty in the event of preloading.
        case metadata(qoe: DateInterval, qos: DateInterval)

        /// The asset is ready to play.
        ///
        /// The date interval corresponding to the process is provided as associated value. Note that this interval
        /// measures the perceived user experience and might be empty in the event of preloading.
        case asset(qoe: DateInterval)

        /// Failure.
        case failure(Error)

        /// Warning.
        case warning(Error)

        /// Stall.
        case stall

        /// Resume after stall.
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
        case let .metadata(qoe: qoe, qos: qos):
            return "Metadata: qoe = \(Self.duration(from: qoe.duration)), qos = \(Self.duration(from: qos.duration))"
        case let .asset(qoe: dateInterval):
            return "Asset: \(Self.duration(from: dateInterval.duration))"
        case let .failure(error):
            return "Failure: \(error.localizedDescription)"
        case let .warning(error):
            return "Warning: \(error.localizedDescription)"
        case .stall:
            return "Stall"
        case .resumeAfterStall:
            return "Resume after stall"
        }
    }

    private static func duration(from interval: TimeInterval) -> String {
        String(format: "%.6fs", interval)
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
