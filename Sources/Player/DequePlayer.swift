//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class DequePlayer: AVQueuePlayer {
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

extension Notification.Name {
    static let willSeek = Notification.Name("DequePlayerWillSeekNotification")
    static let didSeek = Notification.Name("DequePlayerDidSeekNotification")
}
