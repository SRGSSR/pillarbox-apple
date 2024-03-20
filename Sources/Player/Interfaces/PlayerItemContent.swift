//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol describing content associated with a player item.
protocol PlayerItemContent {
    associatedtype Metadata

    var id: UUID { get }
    var resource: Resource { get }
    var metadataAdapter: MetadataAdapter<Metadata> { get }
    var trackerAdapters: [TrackerAdapter<Metadata>] { get }

    func updateMetadata()

    func configure(item: AVPlayerItem)
    func update(item: AVPlayerItem)
}

extension PlayerItemContent {
    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        id == playerItem?.id
    }

    func enableTrackers(for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func disableTrackers() {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }

    func playerItem(reload: Bool = false) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configure(item: item)
            update(item: item)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configure(item: item)
            update(item: item)
            PlayerItem.load(for: id)
            return item
        }
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        metadataAdapter.mediaItemInfo(with: error)
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
    /// - Returns: The list of player items to load into the player.
    static func playerItems(
        for currentContents: [any PlayerItemContent],
        replacing previousContents: [any PlayerItemContent],
        currentItem: AVPlayerItem?,
        length: Int
    ) -> [AVPlayerItem] {
        guard let currentItem else { return playerItems(from: Array(currentContents.prefix(length))) }
        if let currentIndex = matchingIndex(for: currentItem, in: currentContents) {
            let currentContent = currentContents[currentIndex]
            if findContent(currentContent, in: previousContents) {
                currentContent.update(item: currentItem)
                return [currentItem] + playerItems(from: Array(currentContents.suffix(from: currentIndex + 1).prefix(length - 1)))
            }
            else {
                return playerItems(from: Array(currentContents.suffix(from: currentIndex).prefix(length)))
            }
        }
        else if let commonIndex = firstCommonIndex(in: currentContents, matching: previousContents, after: currentItem) {
            return playerItems(from: Array(currentContents.suffix(from: commonIndex).prefix(length)))
        }
        else {
            return playerItems(from: Array(currentContents.prefix(length)))
        }
    }

    static func playerItems(from contents: [any PlayerItemContent], reload: Bool = false) -> [AVPlayerItem] {
        contents.map { $0.playerItem(reload: reload) }
    }

    private static func matchingIndex(for item: AVPlayerItem, in contents: [any PlayerItemContent]) -> Int? {
        contents.firstIndex { $0.matches(item) }
    }

    private static func firstMatchingIndex(for contents: [any PlayerItemContent], in other: [any PlayerItemContent]) -> Int? {
        guard let match = contents.first(where: { content in
            other.contains(where: { $0.id == content.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: other)
    }

    private static func matchingIndex(for content: any PlayerItemContent, in contents: [any PlayerItemContent]) -> Int? {
        contents.firstIndex { $0.id == content.id }
    }

    private static func findContent(_ content: any PlayerItemContent, in contents: [any PlayerItemContent]) -> Bool {
        guard let match = contents.first(where: { $0.id == content.id }) else { return false }
        return match.resource == content.resource
    }

    private static func firstCommonIndex(in contents: [any PlayerItemContent], matching other: [any PlayerItemContent], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: contents)
    }
}
