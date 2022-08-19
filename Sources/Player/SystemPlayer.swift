//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class SystemPlayer: AVQueuePlayer {
    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {

        NotificationCenter.default.post(name: .willSeek, object: self, userInfo: [
            SeekInfoKey.targetTime: time
        ])
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { finished in
            if finished {
                NotificationCenter.default.post(name: .didSeek, object: self)
            }
            completionHandler(finished)
        }
    }
}

extension SystemPlayer {
    enum SeekInfoKey: String {
        case targetTime
    }
}

/// Can be posted from any thread
extension Notification.Name {
    static let willSeek = Notification.Name("SystemPlayerWillSeekNotification")
    static let didSeek = Notification.Name("SystemPlayerDidSeekNotification")
}
