//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum ItemState: Equatable {
    case unknown
    case readyToPlay
    case ended
    case failed(error: Error)

    static func == (lhs: ItemState, rhs: ItemState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.readyToPlay, .readyToPlay), (.ended, .ended):
            return true
        case let (.failed(error: lhsError), .failed(error: rhsError)):
            return lhsError as NSError == rhsError as NSError
        default:
            return false
        }
    }

    static func itemState(for item: AVPlayerItem?) -> ItemState {
        guard let item else { return .unknown }
        switch item.status {
        case .readyToPlay:
            return .readyToPlay
        case .failed:
            return .failed(error: error(for: item))
        default:
            return .unknown
        }
    }

    static func friendlyComment(from comment: String?) -> String? {
        // For some reason extended delimiters are currently required for compilation to succeed in Swift Packages.
        let regex = #/.* \(.* error -?\d+ - (.*)\)/#
        guard let comment, let result = try? regex.wholeMatch(in: comment) else { return comment }
        return String(result.1)
    }

    private static func userInfo(for event: AVPlayerItemErrorLogEvent) -> [String: Any] {
        guard let comment = friendlyComment(from: event.errorComment) else { return [:] }
        return [NSLocalizedDescriptionKey: comment]
    }

    private static func error(for item: AVPlayerItem) -> Error {
        if let errorLog = item.errorLog(), let event = errorLog.events.last {
            return NSError(
                domain: event.errorDomain,
                code: event.errorStatusCode,
                userInfo: userInfo(for: event)
            )
        }
        else {
            return item.error ?? PlaybackError.unknown
        }
    }
}
