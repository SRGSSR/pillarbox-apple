//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private var pendingSeeks = Deque<Seek>()
    var blockedTimeRanges: [CMTimeRange] = []

    // Starting with iOS 17 accessing media selection criteria might be slow. Use a cache for the lifetime of the
    // player.
    private var mediaSelectionCriteria: [AVMediaCharacteristic: AVPlayerMediaSelectionCriteria?] = [:]

    private var targetSeek: Seek? {
        pendingSeeks.last
    }

    var targetSeekTime: CMTime? {
        targetSeek?.position.time
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

        let seek = unblockedSeek(Seek(
            to(time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter),
            isSmooth: smooth,
            completionHandler: completionHandler
        ))

        notifySeekStart(at: seek.position.time)
        pendingSeeks.append(seek)

        if seek.isSmooth && pendingSeeks.count != 1 {
            return
        }

        enqueue(seek: seek) { [weak self] in
            guard let self else { return }
            notifySeekEnd()
        }
    }

    func enqueue(seek: Seek, completion: @escaping () -> Void) {
        self.seek(safelyTo: seek.position) { [weak self] finished in
            self?.process(seek: seek, finished: finished, completion: completion)
        }
    }

    private func seek(safelyTo position: Position, completionHandler: @escaping (Bool) -> Void) {
        let endTimeRange = CMTimeRange(start: timeRange.end - CMTime(value: 18, timescale: 1), end: timeRange.end)
        if duration.isIndefinite || !endTimeRange.containsTime(position.time) {
            super.seek(
                to: position.time,
                toleranceBefore: position.toleranceBefore,
                toleranceAfter: position.toleranceAfter,
                completionHandler: completionHandler
            )
        }
        else {
            super.seek(
                to: position.time,
                toleranceBefore: .zero,
                toleranceAfter: .zero,
                completionHandler: completionHandler
            )
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

    private func unblockedSeek(_ seek: Seek) -> Seek {
        guard let allowedPosition = seek.position.after(blockedTimeRanges) else { return seek }
        return Seek(allowedPosition, isSmooth: false, completionHandler: seek.completionHandler)
    }

    override func mediaSelectionCriteria(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> AVPlayerMediaSelectionCriteria? {
        if let cachedCriteria = mediaSelectionCriteria[mediaCharacteristic] {
            return cachedCriteria
        }
        else {
            let criteria = super.mediaSelectionCriteria(forMediaCharacteristic: mediaCharacteristic)
            mediaSelectionCriteria[mediaCharacteristic] = criteria
            return criteria
        }
    }

    override func setMediaSelectionCriteria(_ criteria: AVPlayerMediaSelectionCriteria?, forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) {
        mediaSelectionCriteria[mediaCharacteristic] = criteria
        super.setMediaSelectionCriteria(criteria, forMediaCharacteristic: mediaCharacteristic)
    }
}
