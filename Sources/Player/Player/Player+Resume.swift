//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension Player {
    /// Resumes playback at the specified position in the given item.
    ///
    /// - Parameters:
    ///   - position: The position to resume from. If `.zero` is provided, playback efficiently resumes at the
    ///     default position:
    ///
    ///     - Zero for on-demand streams.
    ///     - Live edge for DVR-enabled livestreams.
    ///
    ///     > Note: Resuming at the default position is always efficient, regardless of the requested tolerances.
    ///
    ///   - item: The item to resume. The method has no effect if the item is not part of the current item list.
    ///
    /// This method can be used not only during active playback, but also to set the initial item and position for a
    /// player immediately after creation.
    ///
    /// > Note: To consistently start playback of an item at a specific position, use ``PlaybackConfiguration/position``
    ///   instead. Calling ``resume(_:in:)`` overrides this setting temporarily.
    func resume(_ position: Position, in item: PlayerItem) {
        guard items.contains(item) else { return }
        if item == currentItem, canSeek(to: position.time) {
            seek(position)
        }
        else {
            resumeState = .init(position: position, id: item.id)
            currentItem = item
        }
    }
}
