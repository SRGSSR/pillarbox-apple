//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct Queue {
    static let empty = Self(elements: [], itemState: .empty)

    let elements: [QueueElement]
    let itemState: ItemState

    var index: Int? {
        elements.firstIndex { $0.matches(itemState.item) }
    }

    var item: PlayerItem? {
        guard let index else { return nil }
        return elements[index].item
    }

    var error: Error? {
        itemState.error
    }

    var displayableError: Error? {
        if let item = itemState.item {
            return ItemError.intrinsicError(for: item) ?? itemState.error
        }
        else {
            return itemState.error
        }
    }

    private var playerItem: AVPlayerItem? {
        itemState.item
    }

    init(elements: [QueueElement], itemState: ItemState) {
        self.elements = elements
        self.itemState = !elements.isEmpty ? itemState : .empty
    }

    // swiftlint:disable:next discouraged_optional_collection
    static func playerItems(from previous: Self, to current: Self, length: Int) -> [AVPlayerItem]? {
        if let previousItem = previous.playerItem, previous.error != nil {
            return [previousItem]
        }
        else if let currentItem = current.playerItem, current.error != nil {
            return [currentItem]
        }
        // TODO: Can probably merge both `AVPlayerItem.playerItems` below
        else if let currentItem = current.playerItem {
            return AVPlayerItem.playerItems(
                for: current.elements.map(\.asset),
                replacing: previous.elements.map(\.asset),
                currentItem: currentItem,
                length: length
            )
        }
        else if previous.playerItem != nil {
            return nil
        }
        else {
            return AVPlayerItem.playerItems(
                for: current.elements.map(\.asset),
                replacing: previous.elements.map(\.asset),
                currentItem: nil,
                length: length
            )
        }
    }

    func updated(with update: QueueUpdate) -> Self {
        switch update {
        case let .elements(elements):
            return .init(elements: elements, itemState: itemState)
        case let .itemState(itemState):
            return .init(elements: elements, itemState: itemState)
        }
    }
}
