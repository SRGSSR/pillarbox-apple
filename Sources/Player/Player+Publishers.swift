//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import DequeModule
import Foundation

extension Player {
    struct Current: Equatable {
        let item: PlayerItem
        let index: Int
    }

    func currentPublisher() -> AnyPublisher<Current?, Never> {
        itemUpdatePublisher()
            .map { update in
                guard let currentIndex = update.currentIndex() else { return nil }
                return .init(item: update.items[currentIndex], index: currentIndex)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension Player {
    struct ItemUpdate {
        let items: Deque<PlayerItem>
        let currentItem: AVPlayerItem?

        func currentIndex() -> Int? {
            items.firstIndex { $0.matches(currentItem) }
        }

        func streamTypePublisher() -> AnyPublisher<StreamType, Never> {
            guard let currentItem else { return Just(.unknown).eraseToAnyPublisher() }
            return currentItem.streamTypePublisher().eraseToAnyPublisher()
        }
    }

    func assetsPublisher() -> AnyPublisher<[any Assetable], Never> {
        $storedItems
            .map { items in
                Publishers.AccumulateLatestMany(items.map { item in
                    item.$asset
                })
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func itemUpdatePublisher() -> AnyPublisher<ItemUpdate, Never> {
        Publishers.CombineLatest($storedItems, $currentItem)
            .map { items, currentItem in
                let playerItem = Self.smoothPlayerItem(for: currentItem, in: items)
                return ItemUpdate(items: items, currentItem: playerItem)
            }
            .eraseToAnyPublisher()
    }

    func nowPlayingInfoMetadataPublisher() -> AnyPublisher<NowPlaying.Info, Never> {
        currentPublisher()
            .map { current in
                guard let current else {
                    return Just(NowPlaying.Info()).eraseToAnyPublisher()
                }
                return current.item.$asset
                    .map { $0.nowPlayingInfo() }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates { lhs, rhs in
                // swiftlint:disable:next legacy_objc_type
                NSDictionary(dictionary: lhs).isEqual(to: rhs)
            }
            .eraseToAnyPublisher()
    }
}
