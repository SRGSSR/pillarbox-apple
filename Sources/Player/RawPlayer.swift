//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class RawPlayer: AVQueuePlayer {
    private var seekCount = 0

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        if seekCount == 0 {
            NotificationCenter.default.post(name: .willSeek, object: self)
        }
        seekCount += 1
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { finished in
            self.seekCount -= 1
            if self.seekCount == 0 {
                NotificationCenter.default.post(name: .didSeek, object: self)
            }
            completionHandler(finished)
        }
    }

    func replaceItems(with items: [AVPlayerItem]) {
        if self.items().count > 1 {
            self.items().suffix(from: 1).forEach { item in
                remove(item)
            }
            items.forEach { item in
                insert(item, after: nil)
            }
            advanceToNextItem()
        }
        else {
            replaceCurrentItem(with: items.first)
        }
    }
}

extension Notification.Name {
    static let willSeek = Notification.Name("RawPlayerWillSeekNotification")
    static let didSeek = Notification.Name("RawPlayerDidSeekNotification")
}
