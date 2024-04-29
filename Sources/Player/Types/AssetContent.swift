//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import AVKit

struct AssetContent {
    let id: UUID
    let resource: Resource
    let metadata: PlayerMetadata
    let configuration: PlayerItemConfiguration

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading, metadata: .empty, configuration: .init())
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty, configuration: .init())
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = metadata.externalMetadata
#if os(tvOS)
        item.interstitialTimeRanges = metadata.blockedTimeRanges.map { timeRange in
            .init(timeRange: .init(start: timeRange.start, end: timeRange.end))
        }
        item.navigationMarkerGroups = [
            AVNavigationMarkersGroup(title: "chapters", timedNavigationMarkers: metadata.timedNavigationMarkers)
        ]
#endif
    }

    func playerItem(reload: Bool = false) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configuration.apply(to: item, with: metadata)
            update(item: item)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configuration.apply(to: item, with: metadata)
            update(item: item)
            PlayerItem.load(for: id)
            return item
        }
    }
}
