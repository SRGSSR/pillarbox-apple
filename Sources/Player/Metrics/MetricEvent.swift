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
        /// Two associated durations are provided, measuring metadata retrieval from an end-user, respectively from a
        /// technical perspective.
        case metadata(experience: Duration, service: Duration)

        /// The asset is ready to play.
        ///
        /// An associated duration is provided, measuring asset retrieval from an end-user perspective.
        case asset(experience: Duration)

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
    public let date = Date()

    /// The player time.
    ///
    /// Might be `.invalid`.
    public let time: CMTime

    init(kind: Kind, time: CMTime = .invalid) {
        self.kind = kind
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
            return "Metadata: \(Self.duration(from: experience.timeInterval())) (experience), \(Self.duration(from: service.timeInterval())) (service)"
        case let .asset(experience: experience):
            return "Asset: \(Self.duration(from: experience.timeInterval())) (experience)"
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
    private static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private static let durationFormatter = {
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
