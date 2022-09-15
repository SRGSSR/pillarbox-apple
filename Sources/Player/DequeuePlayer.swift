//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

@MainActor
public final class DequeuePlayer: AVQueuePlayer {
    private var seekCount = 0

    /// Check whether an item can be inserted before another item. An item can appear once at most in a dequeue.
    /// - Parameters:
    ///   - item: The item to be tested.
    ///   - beforeItem: The item before which insertion should take place. Pass `nil` to check insertion at the front
    ///     of the dequeue.
    /// - Returns: `true` iff the tested item can be inserted.
    func canInsert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) -> Bool {
        return false
    }

    /// Insert an item before another item. Does nothing if the item already belongs to the dequeue.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the dequeue.
    func insert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
    }

    /// All items in the dequeue.
    /// - Returns: Items
    public override func items() -> [AVPlayerItem] {
        return super.items()
    }

    /// Items past the current item (not included).
    /// - Returns: Items.
    func nextItems() -> [AVPlayerItem] {
        return []
    }

    /// Items before the current item (not included).
    /// - Returns: Items.
    func previousItems() -> [AVPlayerItem] {
        return []
    }

    /// Return to the previous item in the dequeue.
    func returnToPreviousItem() {
    }

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
    static let willSeek = Notification.Name("DequeuePlayerWillSeekNotification")
    static let didSeek = Notification.Name("DequeuePlayerDidSeekNotification")
}
