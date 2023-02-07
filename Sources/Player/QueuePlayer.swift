//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

enum SeekKey: String {
    case time
}

final class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private(set) var seekTime: CMTime?

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, isSmooth: false, completionHandler: completionHandler)
    }

    func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, isSmooth: Bool, completionHandler: @escaping (Bool) -> Void) {
        guard !items().isEmpty else {
            completionHandler(false)
            return
        }
        Self.notificationCenter.post(name: .willSeek, object: self, userInfo: [
            SeekKey.time: time
        ])
        if isSmooth, seekTime != nil {
            seekTime = time
            return
        }
        seekTime = time
        _seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] finished in
            guard let self else { return }
            self.seekTime = nil
            if isSmooth || finished {
                Self.notificationCenter.post(name: .didSeek, object: self)
            }
            completionHandler(finished)
        }
    }

    func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, isSmooth: Bool) async -> Bool {
        await withCheckedContinuation { continuation in
            seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, isSmooth: isSmooth) { finished in
                continuation.resume(returning: finished)
            }
        }
    }

    private func _seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] finished in
            guard let self else { return }
            guard let seekTime = self.seekTime else { return completionHandler(finished) }
            if seekTime != time, finished {
                self._seek(to: seekTime, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
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
