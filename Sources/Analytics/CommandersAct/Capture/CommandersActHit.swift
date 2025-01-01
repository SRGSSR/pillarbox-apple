//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A hit made by the Commanders Act SDK.
///
/// Mainly used for development-oriented purposes (e.g., unit testing).
public struct CommandersActHit {
    /// A name describing a Commanders Act hit.
    public enum Name: Equatable {
        case play
        case pause
        case seek
        case stop
        case eof
        case pos
        case uptime
        case page_view
        case custom(String)

        /// Returns the hit raw representation.
        public var rawValue: String {
            switch self {
            case .play:
                return "play"
            case .pause:
                return "pause"
            case .seek:
                return "seek"
            case .stop:
                return "stop"
            case .eof:
                return "eof"
            case .pos:
                return "pos"
            case .uptime:
                return "uptime"
            case .page_view:
                return "page_view"
            case let .custom(name):
                return name
            }
        }

        /// Creates a hit from a raw string.
        public init?(rawValue: String?) {
            // swiftlint:disable:previous cyclomatic_complexity
            guard let rawValue else { return nil }
            switch rawValue {
            case "play":
                self = .play
            case "pause":
                self = .pause
            case "seek":
                self = .seek
            case "stop":
                self = .stop
            case "eof":
                self = .eof
            case "pos":
                self = .pos
            case "uptime":
                self = .uptime
            case "page_view":
                self = .page_view
            default:
                self = .custom(rawValue)
            }
        }
    }

    /// The hit name.
    public let name: Name

    /// The labels associated with the hit.
    public let labels: CommandersActLabels

    init?(from labels: CommandersActLabels) {
        guard let name = Name(rawValue: labels.event_name ?? "") else { return nil }
        self.name = name
        self.labels = labels
    }
}

extension CommandersActHit: CustomDebugStringConvertible {
    public var debugDescription: String {
        name.rawValue
    }
}
