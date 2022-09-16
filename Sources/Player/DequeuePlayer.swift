//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

@MainActor
public final class DequeuePlayer: AVQueuePlayer {
    private var seekCount = 0

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

    /// Check whether an item can be inserted before another item. An item can appear once at most in a dequeue.
    /// - Parameters:
    ///   - item: The item to be tested.
    ///   - beforeItem: The item before which insertion should take place. Pass `nil` to check insertion at the front
    ///     of the dequeue.
    /// - Returns: `true` iff the tested item can be inserted.
    func canInsert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) -> Bool {
        // Same logic as "insertion after" applies
        canInsert(item, after: beforeItem)
    }

    /// Insert an item before another item. Does nothing if the item already belongs to the dequeue.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the dequeue.
    func insert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
    }

    /// Insert an item after another item. Does nothing if the item already belongs to the dequeue.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the end of
    ///     the queue.
    public override func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        guard canInsert(item, after: afterItem) else { return }
        super.insert(item, after: afterItem)
    }

    /// Prepend an item to the queue.
    /// - Parameter item: The item to prepend.
    func prepend(_ item: AVPlayerItem) {
        insert(item, before: nil)
    }

    /// Append an item to the queue.
    /// - Parameter item: The item to append.
    func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    /// Move an item before another item.
    /// - Parameters:
    ///   - item: The item to move.
    ///   - beforeItem: The item before which the moved item must be relocated. Pass `nil` to move the item to the
    ///     front of the queue.
    func move(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
    }

    /// Move an item after another item.
    /// - Parameters:
    ///   - item: The item to move.
    ///   - afterItem: The item after which the moved item must be relocated. Pass `nil` to move the item to the
    ///     end of the queue.
    func move(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
    }

    /// Remove an item from the queue
    /// - Parameter item: The item to remove.
    public override func remove(_ item: AVPlayerItem) {
        super.remove(item)
    }

    /// Remove all items in the queue.
    public override func removeAllItems() {
        super.removeAllItems()
    }

    /// Return to the previous item in the dequeue.
    func returnToPreviousItem() {
    }

    /// Move to the next item in the dequeue.
    public override func advanceToNextItem() {
        super.advanceToNextItem()
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
