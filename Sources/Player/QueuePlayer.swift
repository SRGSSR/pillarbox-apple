//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private var seekCount = 0

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        guard !items().isEmpty else {
            return completionHandler(false)
        }
        if seekCount == 0 {
            Self.notificationCenter.post(name: .willSeek, object: self)
        }
        seekCount += 1
        Self.notificationCenter.post(name: .seek, object: self, userInfo: [
            SeekKey.time: time
        ])
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] finished in
            guard let self else { return }
            self.seekCount -= 1
            if self.seekCount == 0 {
                Self.notificationCenter.post(name: .didSeek, object: self)
            }
            completionHandler(finished)
        }
    }

    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        self.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, completionHandler: completionHandler)
    }

    override func seek(to time: CMTime) {
        self.seek(to: time, completionHandler: { _ in })
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
    static let seek = Notification.Name("QueuePlayerSeekNotification")
    static let didSeek = Notification.Name("QueuePlayerDidSeekNotification")
}

enum SeekKey: String {
    case time
}
