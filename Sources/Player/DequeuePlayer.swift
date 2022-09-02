//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

// TODO: Must later implement dequeue support for items to have playlist support in forward and backward directions.
@MainActor
public final class DequeuePlayer: AVQueuePlayer {
    private var seekCount = 0

    override public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        if seekCount == 0 {
            NotificationCenter.default.post(name: .willSeek, object: self)
        }
        seekCount += 1
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { finished in
            self.seekCount -= 1
            if finished {
                assert(self.seekCount == 0)
                NotificationCenter.default.post(name: .didSeek, object: self)
            }
            completionHandler(finished)
        }
    }
}

/// Can be posted from any thread.
extension Notification.Name {
    static let willSeek = Notification.Name("DequeuePlayerWillSeekNotification")
    static let didSeek = Notification.Name("DequeuePlayerDidSeekNotification")
}
