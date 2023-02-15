//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import DequeModule

enum SeekKey: String {
    case time
}

private struct Seek {
    let time: CMTime
    let isSmooth: Bool
    let completionHandler: (Bool) -> Void
}

final class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private var targetSeek: Seek?
    private var pendingSeeks = Deque<Seek>()

    var timeRange: CMTimeRange {
        currentItem?.timeRange ?? .invalid
    }

    var targetSeekTime: CMTime? {
        targetSeek?.time
    }

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, smooth: false, completionHandler: completionHandler)
    }

    func seek(
        to time: CMTime,
        toleranceBefore: CMTime = .positiveInfinity,
        toleranceAfter: CMTime = .positiveInfinity,
        smooth: Bool,
        completionHandler: @escaping (Bool) -> Void
    ) {
        assert(time.isValid)

        guard !items().isEmpty else {
            completionHandler(true)
            return
        }

        Self.notificationCenter.post(name: .willSeek, object: self, userInfo: [SeekKey.time: time])

        if let targetSeek {
            pendingSeeks.append(targetSeek)
        }
        targetSeek = Seek(time: time, isSmooth: smooth, completionHandler: completionHandler)

        if smooth && !pendingSeeks.isEmpty {
            return
        }

        move(to: targetSeek, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] _ in
            guard let self else { return }
            Self.notificationCenter.post(name: .didSeek, object: self)
        }
    }

    private func move(to seek: Seek?, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        guard let seek else { return }
        super.seek(to: seek.time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] finished in
            guard let self else { return }
            while let pendingSeek = self.pendingSeeks.popFirst() {
                pendingSeek.completionHandler(finished)
            }
            if let targetSeek = self.targetSeek, targetSeek.time == seek.time {
                targetSeek.completionHandler(true)
                completionHandler(true)
                self.targetSeek = nil
            }
            else if let targetSeek = self.targetSeek, targetSeek.isSmooth {
                self.move(
                    to: targetSeek,
                    toleranceBefore: toleranceBefore,
                    toleranceAfter: toleranceAfter,
                    completionHandler: completionHandler
                )
            }
            else {
                completionHandler(finished)
            }
        }
    }

    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        self.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, completionHandler: completionHandler)
    }

    override func seek(to time: CMTime) {
        self.seek(to: time) { _ in }
    }

    func replaceItems(with items: [AVPlayerItem]) {
        cancelPendingReplacements()

        guard self.items() != items else { return }

        if let firstItem = items.first {
            if firstItem !== self.items().first {
                removeAllItems()
                replaceCurrentItem(with: firstItem)
            }
            else if self.items().count > 1 {
                self.items().suffix(from: 1).forEach { item in
                    remove(item)
                }
            }
            if items.count > 1 {
                perform(#selector(append(_:)), with: Array(items.suffix(from: 1)), afterDelay: 1, inModes: [.common])
            }
        }
        else {
            removeAllItems()
        }
    }

    @objc
    private func append(_ items: [AVPlayerItem]) {
        items.forEach { item in
            insert(item, after: nil)
        }
    }

    func cancelPendingReplacements() {
        RunLoop.cancelPreviousPerformRequests(withTarget: self)
    }
}

extension Notification.Name {
    static let willSeek = Notification.Name("QueuePlayerWillSeekNotification")
    static let didSeek = Notification.Name("QueuePlayerDidSeekNotification")
}
