//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

struct RawPlayerMetadata: Equatable {
    static let empty = Self(items: [], timedGroups: [], chapterGroups: [])

    let items: [AVMetadataItem]
    let timedGroups: [AVTimedMetadataGroup]
    let chapterGroups: [AVTimedMetadataGroup]

    func publisher(bestMatchingPreferredLanguages preferredLanguages: [String]) -> AnyPublisher<PlayerMetadata._Data, Never> {
        Publishers.CombineLatest3(
            AVMetadataItem.publisher(for: items, bestMatchingPreferredLanguages: preferredLanguages),
            AVTimedMetadataGroup.publisher(for: timedGroups, bestMatchingPreferredLanguages: preferredLanguages),
            AVTimedMetadataGroup.publisher(for: chapterGroups, bestMatchingPreferredLanguages: preferredLanguages)
        )
        .map { .init(items: $0, timedGroups: $1, chapterGroups: $2) }
        .eraseToAnyPublisher()
    }
}

private extension AVMetadataItem {
    static func publisher(
        for items: [AVMetadataItem],
        bestMatchingPreferredLanguages preferredLanguages: [String]
    ) -> AnyPublisher<[MetadataItem], Never> {
        let filteredItems = AVMetadataItem.metadataItems(
            from: items,
            filteredAndSortedAccordingToPreferredLanguages: preferredLanguages
        )
        return Publishers.AccumulateLatestMany(filteredItems.map { item in
            item.propertyPublisher(.value)
                .replaceError(with: nil)
                .compactMap { value -> MetadataItem? in
                    guard let value, let identifier = item.identifier else {
                        return nil
                    }
                    return .init(identifier: identifier, value: value)
                }
        })
        .prepend([])
        .eraseToAnyPublisher()
    }
}

private extension AVTimedMetadataGroup {
    static func publisher(
        for groups: [AVTimedMetadataGroup],
        bestMatchingPreferredLanguages preferredLanguages: [String]
    ) -> AnyPublisher<[TimedMetadataGroup], Never> {
        Publishers.AccumulateLatestMany(groups.map { group in
            publisher(for: group, bestMatchingPreferredLanguages: preferredLanguages)
        })
        .prepend([])
        .eraseToAnyPublisher()
    }

    private static func publisher(
        for group: AVTimedMetadataGroup,
        bestMatchingPreferredLanguages preferredLanguages: [String]
    ) -> AnyPublisher<TimedMetadataGroup, Never> {
        AVMetadataItem.publisher(for: group.items, bestMatchingPreferredLanguages: preferredLanguages)
            .map { TimedMetadataGroup(items: $0, timeRange: group.timeRange) }
            .eraseToAnyPublisher()
    }
}
