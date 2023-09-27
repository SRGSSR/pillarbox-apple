//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import DequeModule
import os

enum SeekKey: String {
    case time
}

struct Seek: Equatable {
    let time: CMTime
    let toleranceBefore: CMTime
    let toleranceAfter: CMTime
    let isSmooth: Bool
    let completionHandler: (Bool) -> Void

    private let id = UUID()

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private static let logger = Logger(category: "QueuePlayer")

    private var pendingSeeks = Deque<Seek>()
    private var cancellables = Set<AnyCancellable>()

    private var targetSeek: Seek? {
        pendingSeeks.last
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

        notifySeekStart(at: time)

        let seek = Seek(
            time: time,
            toleranceBefore: toleranceBefore,
            toleranceAfter: toleranceAfter,
            isSmooth: smooth,
            completionHandler: completionHandler
        )
        pendingSeeks.append(seek)

        if smooth && pendingSeeks.count != 1 {
            return
        }

        enqueue(seek: seek) { [weak self] in
            guard let self else { return }
            notifySeekEnd()
        }
    }

    func enqueue(seek: Seek, completion: @escaping () -> Void) {
        self.seek(safelyTo: seek.time, toleranceBefore: seek.toleranceBefore, toleranceAfter: seek.toleranceAfter) { [weak self] finished in
            self?.process(seek: seek, finished: finished, completion: completion)
        }
    }

    private func seek(safelyTo time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        let endTimeRange = CMTimeRange(start: timeRange.end - CMTime(value: 18, timescale: 1), end: timeRange.end)
        if itemDuration.isIndefinite || !endTimeRange.containsTime(time) {
            super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
        }
        else {
            super.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completionHandler)
        }
    }

    private func process(seek: Seek, finished: Bool, completion: @escaping () -> Void) {
        if let targetSeek, seek != targetSeek {
            while let pendingSeek = pendingSeeks.first, pendingSeek != targetSeek {
                pendingSeeks.removeFirst()
                pendingSeek.completionHandler(targetSeek.isSmooth)
            }
            if finished {
                enqueue(seek: targetSeek, completion: completion)
            }
        }
        else if finished {
            completion()
            seek.completionHandler(finished)
            pendingSeeks.removeAll()
        }
        else {
            // Sometimes the target seek might fail for no reason, especially when seeking near the stream end.
            // In such cases retry.
            enqueue(seek: seek, completion: completion)
        }
    }

    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, completionHandler: completionHandler)
    }

    override func seek(to time: CMTime) {
        seek(to: time) { _ in }
    }

    private func notifySeekStart(at time: CMTime) {
        Self.notificationCenter.post(name: .willSeek, object: self, userInfo: [SeekKey.time: time])
    }

    private func notifySeekEnd() {
        Self.notificationCenter.post(name: .didSeek, object: self)
    }
}

extension AVQueuePlayer {
    func replaceItems(with items: [AVPlayerItem]) {
        cancelPendingReplacements()

        guard self.items() != items else { return }

        if let firstItem = items.first {
            if firstItem !== self.items().first {
                removeAll(from: 1)
                replaceCurrentItem(with: firstItem)
            }
            else {
                removeAll(from: 1)
            }
            if items.count > 1 {
                perform(#selector(append(_:)), with: Array(items.suffix(from: 1)), afterDelay: 1, inModes: [.common])
            }
        }
        else {
            removeAllItems()
        }
    }

    private func removeAll(from index: Int) {
        guard items().count > index else { return }
        items().suffix(from: index).forEach { item in
            remove(item)
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

extension QueuePlayer {
    /// Performs a low-level seek without seek tracking.
    private func rawSeek(to time: CMTime) {
        super.seek(to: time)
    }
}

extension Notification.Name {
    static let willSeek = Notification.Name("QueuePlayerWillSeekNotification")
    static let didSeek = Notification.Name("QueuePlayerDidSeekNotification")
}
