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

    init(
        id: UUID,
        resource: Resource,
        metadata: Player.Metadata = .empty
    ) {
        self.id = id
        self.resource = resource
        self.metadata = metadata
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        id == playerItem?.id
    }

    func matches(_ content: ItemContent) -> Bool {
        id == content.id
    }

    func isIdentical(to content: ItemContent) -> Bool {
        matches(content) && resource == content.resource
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
        for currentElements: [QueueElement],
        replacing previousElements: [QueueElement],
        currentItem: AVPlayerItem?,
        length: Int
    ) -> [AVPlayerItem] {
        guard let currentItem else { return playerItems(from: Array(currentElements.prefix(length))) }
        if let currentIndex = matchingIndex(for: currentItem, in: currentElements) {
            let currentElement = currentElements[currentIndex]
            if findIdentical(currentElement, in: previousElements) {
                // currentElement.update(item: currentItem)
                return [currentItem] + playerItems(from: Array(currentElements.suffix(from: currentIndex + 1).prefix(length - 1)))
            }
            else {
                return playerItems(from: Array(currentElements.suffix(from: currentIndex).prefix(length)))
            }
        }
        else if let commonIndex = firstCommonIndex(in: currentElements, matching: previousElements, after: currentItem) {
            return playerItems(from: Array(currentElements.suffix(from: commonIndex).prefix(length)))
        }
        else {
            return playerItems(from: Array(currentElements.prefix(length)))
        }
    }

    static func playerItems(from elements: [QueueElement], reload: Bool = false) -> [AVPlayerItem] {
        elements.map { $0.playerItem(reload: reload) }
    }

    private static func matchingIndex(for item: AVPlayerItem, in elements: [QueueElement]) -> Int? {
        elements.firstIndex { $0.matches(item) }
    }

    private static func firstMatchingIndex(of elements: [QueueElement], in otherElements: [QueueElement]) -> Int? {
        guard let match = elements.first(where: { content in
            otherElements.contains(where: { $0.matches(content) })
        }) else {
            return nil
        }
        return otherElements.firstIndex { $0.matches(match) }
    }

    private static func findIdentical(_ element: QueueElement, in elements: [QueueElement]) -> Bool {
        elements.contains { $0.isIdentical(to: element) }
    }

    private static func firstCommonIndex(
        in elements: [QueueElement],
        matching otherElements: [QueueElement],
        after item: AVPlayerItem
    ) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: otherElements) else { return nil }
        return firstMatchingIndex(of: Array(otherElements.suffix(from: matchIndex + 1)), in: elements)
    }
}
