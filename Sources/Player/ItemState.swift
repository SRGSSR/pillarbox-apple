//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var kCachedError: Void?

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
            return .failed(error: consolidatedError(for: item))
        default:
            return .unknown
        }
    }

    static func itemState(for notification: Notification) -> ItemState? {
        switch notification.name {
        case .AVPlayerItemFailedToPlayToEndTime:
            guard let item = notification.object as? AVPlayerItem,
                  let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else {
                return nil
            }
            return .failed(error: consolidatedError(for: item, error: error))
        default:
            return nil
        }
    }

    static func innerComment(from comment: String?) -> String? {
        // For some reason extended delimiters are currently required for compilation to succeed in Swift Packages.
        let regex = #/[^\(\)]* \([^\(\)]* -?\d+ - (.*)\)/#
        guard let comment, let result = try? regex.wholeMatch(in: comment) else { return comment }
        return innerComment(from: String(result.1))
    }

    static func localizedError(from error: Error) -> Error {
        let bridgedError = error as NSError
        var userInfo = bridgedError.userInfo

        // Errors returned through `AVAssetResourceLoader` do not apply correct error localization rules. Fix.
        let descriptionKey = "NSDescription"
        if let description = userInfo[descriptionKey] {
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[descriptionKey] = nil
        }

        return NSError(domain: bridgedError.domain, code: bridgedError.code, userInfo: userInfo)
    }

    private static func userInfo(for event: AVPlayerItemErrorLogEvent) -> [String: Any] {
        guard let comment = innerComment(from: event.errorComment) else { return [:] }
        return [NSLocalizedDescriptionKey: comment]
    }

    /// Consolidate intrinsic error and error log information. Only reliable the first time the item transitions to
    /// the failed status as of iOS and tvOS 16.1.
    private static func intrinsicError(for item: AVPlayerItem) -> Error {
        if let errorLog = item.errorLog(), let event = errorLog.events.last {
            return NSError(
                domain: event.errorDomain,
                code: event.errorStatusCode,
                userInfo: userInfo(for: event)
            )
        }
        else if let error = item.error {
            return localizedError(from: error)
        }
        else {
            return PlaybackError.unknown
        }
    }

    /// Return the error associated with an item. Caches the first encountered error.
    /// - Parameters:
    ///   - item: The item to consider.
    ///   - error: An error related to the item and which might be supplied by another channel (e.g. notification).
    ///     Takes precedence over error information attached to the item when present.
    /// - Returns: The error
    private static func consolidatedError(for item: AVPlayerItem, error: Error? = nil) -> Error {
        if let cachedError = item.cachedError {
            return cachedError
        }
        else if let error {
            let localizedError = localizedError(from: error)
            item.cachedError = localizedError
            return localizedError
        }
        else {
            let intrinsic = intrinsicError(for: item)
            item.cachedError = intrinsic
            return intrinsic
        }
    }
}

/// As of iOS / tvOS 16.1 the error log is cleared when replacing an item with an already failed one in the queue.
/// For this reason we need to cache the error the first time we can extract it, when the error log (if available)
/// is reliable.
private extension AVPlayerItem {
    var cachedError: Error? {
        get {
            objc_getAssociatedObject(self, &kCachedError) as? Error
        }
        set {
            objc_setAssociatedObject(self, &kCachedError, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
