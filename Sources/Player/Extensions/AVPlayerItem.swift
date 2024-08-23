//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private var kIdKey: Void?

extension AVPlayerItem {
    var timeRange: CMTimeRange {
        TimeProperties.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }
}

extension AVPlayerItem: PlaybackResource {
    func contains(url: URL) -> Bool {
        (asset as? AVURLAsset)?.url == url
    }
}

extension AVPlayerItem {
    /// Returns the list of `AVPlayerItems` to load into an `AVQueuePlayer` when a list of contents replaces a previous
    /// one.
    ///
    /// - Parameters:
    ///   - currentContents: The current list of contents.
    ///   - previousContents: The previous list of contents.
    ///   - currentItem: The item currently being played by the player.
    ///   - repeatMode: The current repeat mode setting.
    ///   - length: The maximum number of items to return.
    /// - Returns: The list of player items to load into the player.
    static func playerItems(
        for currentContents: [AssetContent],
        replacing previousContents: [AssetContent],
        currentItem: AVPlayerItem?,
        repeatMode: RepeatMode,
        length: Int
    ) -> [AVPlayerItem] {
        itemSources(for: currentContents, replacing: previousContents, currentItem: currentItem, repeatMode: repeatMode).prefix(length).map { source in
            if let item = source.item {
                // TODO: Turn into `AVPlayer.updated(with:)` method
                source.content.update(item: item)
                return item
            }
            else {
                return source.content.playerItem(reload: false)
            }
        }
    }

    private static func itemSources(
        for currentContents: [AssetContent],
        replacing previousContents: [AssetContent],
        currentItem: AVPlayerItem?,
        repeatMode: RepeatMode
    ) -> [ItemSource] {
        let sources = itemSources(for: currentContents, replacing: previousContents, currentItem: currentItem)
        switch repeatMode {
        case .off:
            return sources
        case .one:
            guard let firstSource = sources.first else { return sources }
            var updatedSources = sources
            updatedSources.insert(.init(content: firstSource.content, item: nil), at: 1)
            return updatedSources
        case .all:
            guard let firstContent = currentContents.first else { return sources }
            var updatedSources = sources
            updatedSources.append(.init(content: firstContent, item: nil))
            return updatedSources
        }
    }

    private static func itemSources(
        for currentContents: [AssetContent],
        replacing previousContents: [AssetContent],
        currentItem: AVPlayerItem?
    ) -> [ItemSource] {
        guard let currentItem else { return newItemSources(from: Array(currentContents)) }
        if let currentIndex = matchingIndex(for: currentItem, in: currentContents) {
            let currentContent = currentContents[currentIndex]
            if findContent(currentContent, in: previousContents) {
                return [.init(content: currentContent, item: currentItem)] + newItemSources(from: Array(currentContents.suffix(from: currentIndex + 1)))
            }
            else {
                return newItemSources(from: Array(currentContents.suffix(from: currentIndex)))
            }
        }
        else if let commonIndex = firstCommonIndex(in: currentContents, matching: previousContents, after: currentItem) {
            return newItemSources(from: Array(currentContents.suffix(from: commonIndex)))
        }
        else {
            return newItemSources(from: Array(currentContents))
        }
    }

    static func playerItems(from items: [PlayerItem], repeatMode: RepeatMode, length: Int, reload: Bool) -> [AVPlayerItem] {
        playerItems(from: items.map(\.content), repeatMode: repeatMode, length: length, reload: reload)
    }

    private static func playerItems(from contents: [AssetContent], repeatMode: RepeatMode, length: Int, reload: Bool = false) -> [AVPlayerItem] {
        contents.map { $0.playerItem(reload: reload) }
    }

    private static func newItemSources(from contents: [AssetContent]) -> [ItemSource] {
        contents.map { .init(content: $0, item: nil) }
    }

    private static func matchingIndex(for item: AVPlayerItem, in contents: [AssetContent]) -> Int? {
        contents.firstIndex { $0.id == item.id }
    }

    private static func firstMatchingIndex(for contents: [AssetContent], in other: [AssetContent]) -> Int? {
        guard let match = contents.first(where: { content in
            other.contains(where: { $0.id == content.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: other)
    }

    private static func matchingIndex(for content: AssetContent, in contents: [AssetContent]) -> Int? {
        contents.firstIndex { $0.id == content.id }
    }

    private static func findContent(_ content: AssetContent, in contents: [AssetContent]) -> Bool {
        guard let match = contents.first(where: { $0.id == content.id }) else { return false }
        return match.resource == content.resource
    }

    private static func firstCommonIndex(in contents: [AssetContent], matching other: [AssetContent], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: contents)
    }
}

extension AVPlayerItem {
    /// An identifier for player items delivered by the same data source.
    private(set) var id: UUID? {
        get {
            objc_getAssociatedObject(self, &kIdKey) as? UUID
        }
        set {
            objc_setAssociatedObject(self, &kIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Assigns an identifier for player items delivered by the same data source.
    ///
    /// - Parameter id: The id to assign.
    /// - Returns: The receiver with the id assigned to it.
    func withId(_ id: UUID) -> AVPlayerItem {
        self.id = id
        return self
    }
}
