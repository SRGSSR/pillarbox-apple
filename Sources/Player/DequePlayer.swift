//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

@MainActor
public final class DequePlayer: AVQueuePlayer {
    private var storedItems: Deque<AVPlayerItem>
    private var seekCount = 0

    /// Create a deque player with the specified items.
    /// - Parameter items: The items to be initially inserted into the deque.
    public override init(items: [AVPlayerItem]) {
        storedItems = Deque()
        super.init(items: items)
    }

    /// Create a deque player with no items.
    public override init() {
        storedItems = Deque()
        super.init()
    }

    /// All items in the deque.
    /// - Returns: Items
    public override func items() -> [AVPlayerItem] {
        Array(storedItems)
    }

    /// Items before the current item (not included).
    /// - Returns: Items.
    public func previousItems() -> [AVPlayerItem] {
        guard let currentItem, let currentIndex = storedItems.firstIndex(of: currentItem) else {
            return Array(storedItems)
        }
        return Array(storedItems.prefix(upTo: currentIndex))
    }

    /// Items past the current item (not included).
    /// - Returns: Items.
    public func nextItems() -> [AVPlayerItem] {
        Array(super.items().dropFirst())
    }

    /// Check whether an item can be inserted before another item. An item can appear once at most in a deque.
    /// - Parameters:
    ///   - item: The item to be tested.
    ///   - beforeItem: The item before which insertion should take place. Pass `nil` to check insertion at the front
    ///     of the deque.
    /// - Returns: `true` iff the tested item can be inserted.
    public func canInsert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) -> Bool {
        guard let beforeItem else { return true }
        return storedItems.contains(beforeItem) && !storedItems.contains(item)
    }

    /// Insert an item before another item. Does nothing if the item already belongs to the deque.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
    ///     of the deque.
    public func insert(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
        guard canInsert(item, before: beforeItem) else { return }
        if let beforeItem {
            guard let index = storedItems.firstIndex(of: beforeItem) else { return }
            storedItems.insert(item, at: index)
            if index != 0 {
                let afterIndex = storedItems.index(before: index)
                super.insert(item, after: storedItems[afterIndex])
            }
        }
        else {
            storedItems.prepend(item)
        }
    }

    /// Check whether an item can be inserted after another item. An item can appear once at most in a deque.
    /// - Parameters:
    ///   - item: The item to be tested.
    ///   - afterItem: The item after which insertion should take place. Pass `nil` to check insertion at the back
    ///     of the deque.
    /// - Returns: `true` iff the tested item can be inserted.
    public override func canInsert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) -> Bool {
        guard let afterItem else { return true }
        return storedItems.contains(afterItem) && !storedItems.contains(item)
    }

    /// Insert an item after another item. Does nothing if the item already belongs to the deque.
    /// - Parameters:
    ///   - item: The item to insert.
    ///   - afterItem: The item after which insertion must take place. Pass `nil` to insert the item at the back of
    ///     the queue.
    public override func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        guard canInsert(item, after: afterItem) else { return }
        if let afterItem {
            guard let index = storedItems.firstIndex(of: afterItem) else { return }
            storedItems.insert(item, at: storedItems.index(after: index))
            super.insert(item, after: afterItem)
        }
        else {
            storedItems.append(item)
            super.insert(item, after: nil)
        }
    }

    /// Prepend an item to the queue.
    /// - Parameter item: The item to prepend.
    public func prepend(_ item: AVPlayerItem) {
        insert(item, before: nil)
    }

    /// Append an item to the queue.
    /// - Parameter item: The item to append.
    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    /// Move an item before another item.
    /// - Parameters:
    ///   - item: The item to move.
    ///   - beforeItem: The item before which the moved item must be relocated. Pass `nil` to move the item to the
    ///     front of the queue.
    public func move(_ item: AVPlayerItem, before beforeItem: AVPlayerItem?) {
    }

    /// Move an item after another item.
    /// - Parameters:
    ///   - item: The item to move.
    ///   - afterItem: The item after which the moved item must be relocated. Pass `nil` to move the item to the
    ///     end of the queue.
    public func move(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
    }

    /// Remove an item from the queue
    /// - Parameter item: The item to remove.
    public override func remove(_ item: AVPlayerItem) {
        storedItems.removeAll { $0 === item }
        super.remove(item)
    }

    /// Remove all items in the queue.
    public override func removeAllItems() {
        storedItems.removeAll()
        super.removeAllItems()
    }

    /// Return to the previous item in the deque.
    public func returnToPreviousItem() {
    }

    /// Move to the next item in the deque.
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
    static let willSeek = Notification.Name("DequePlayerWillSeekNotification")
    static let didSeek = Notification.Name("DequePlayerDidSeekNotification")
}
