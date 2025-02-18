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
        /// Two associated date intervals are provided, respectively measuring when metadata retrieval started / ended from
        /// an end-user or from a technical perspective.
        case metadata(experience: DateInterval, service: DateInterval)

        /// The asset is ready to play.
        ///
        /// An associated date interval is provided, measuring when asset retrieval started / ended from an end-user
        /// perspective.
        case asset(experience: DateInterval)

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

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    // swiftlint:disable:next missing_docs
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MetricEvent.Kind: CustomStringConvertible {
    // swiftlint:disable:next missing_docs
    public var description: String {
        switch self {
        case let .metadata(experience: experience, service: service):
            return "Metadata: \(Self.duration(from: experience.duration)) (experience), \(Self.duration(from: service.duration)) (service)"
        case let .asset(experience: experience):
            return "Asset: \(Self.duration(from: experience.duration)) (experience)"
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

    // swiftlint:disable:next missing_docs
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
