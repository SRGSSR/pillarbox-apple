//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ItemContent {
    let id: UUID
    let resource: Resource
    let metadata: Player.Metadata
    let configuration: ((AVPlayerItem) -> Void)?

    init(
        id: UUID,
        resource: Resource,
        metadata: Player.Metadata = .empty,
        configuration: ((AVPlayerItem) -> Void)? = nil
    ) {
        self.id = id
        self.resource = resource
        self.metadata = metadata
        self.configuration = configuration
    }

    func playerItem(reload: Bool = false) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configuration?(item)
            update(item: item)
            ItemOrchestrator.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configuration?(item)
            update(item: item)
            ItemOrchestrator.load(for: id)
            return item
        }
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        id == playerItem?.id
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = metadata.metadataItems
        // FIXME: On tvOS set navigation markers
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
        for currentContents: [ItemContent],
        replacing previousContents: [ItemContent],
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

    static func playerItems(from contents: [ItemContent], reload: Bool = false) -> [AVPlayerItem] {
        contents.map { $0.playerItem(reload: reload) }
    }

    private static func matchingIndex(for item: AVPlayerItem, in contents: [ItemContent]) -> Int? {
        contents.firstIndex { $0.matches(item) }
    }

    private static func firstMatchingIndex(for contents: [ItemContent], in other: [ItemContent]) -> Int? {
        guard let match = contents.first(where: { content in
            other.contains(where: { $0.id == content.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: other)
    }

    private static func matchingIndex(for content: ItemContent, in contents: [ItemContent]) -> Int? {
        contents.firstIndex { $0.id == content.id }
    }

    private static func findContent(_ content: ItemContent, in contents: [ItemContent]) -> Bool {
        guard let match = contents.first(where: { $0.id == content.id }) else { return false }
        return match.resource == content.resource
    }

    private static func firstCommonIndex(in contents: [ItemContent], matching other: [ItemContent], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: contents)
    }
}
