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
        .init(id: id, resource: .loading, metadata: .empty, configuration: .default)
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty, configuration: .default)
    }

    func update(item: AVPlayerItem, nextContent: AssetContent?) {
        item.externalMetadata = metadata.externalMetadata
#if os(tvOS)
        item.interstitialTimeRanges = CMTimeRange.flatten(metadata.blockedTimeRanges).map { timeRange in
            .init(timeRange: timeRange)
        }
        item.navigationMarkerGroups = [
            AVNavigationMarkersGroup(title: "chapters", timedNavigationMarkers: metadata.timedNavigationMarkers)
        ]
#endif
    }

    func playerItem(reload: Bool = false, nextContent: AssetContent? = nil) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configure(item: item)
            update(item: item, nextContent: nextContent)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configure(item: item)
            update(item: item, nextContent: nextContent)
            PlayerItem.load(for: id)
            return item
        }
    }

    private func configure(item: AVPlayerItem) {
        configuration.apply(to: item, with: metadata)
    }
}
