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

    private var contentProposalTime: CMTime {
        metadata.timeRanges.last { timeRange in
            switch timeRange.kind {
            case let .credits(credits):
                return credits == .closing
            case .blocked:
                return false
            }
        }?.start ?? .indefinite
    }

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading, metadata: .empty, configuration: .default)
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty, configuration: .default)
    }

    private static func contentProposal(for content: Self?, at time: CMTime) -> AVContentProposal? {
        guard let content, let title = content.metadata.title else { return nil }
        return AVContentProposal(
            contentTimeForTransition: time,
            title: title,
            previewImage: content.metadata.image
        )
    }

    func update(item: AVPlayerItem, nextContent: Self?) {
        item.externalMetadata = metadata.externalMetadata
#if os(tvOS)
        item.interstitialTimeRanges = CMTimeRange.flatten(metadata.blockedTimeRanges).map { timeRange in
            .init(timeRange: timeRange)
        }
        item.navigationMarkerGroups = [
            AVNavigationMarkersGroup(title: "chapters", timedNavigationMarkers: metadata.timedNavigationMarkers)
        ]
        item.nextContentProposal = Self.contentProposal(for: nextContent, at: contentProposalTime)
#endif
    }

    func playerItem(reload: Bool = false, nextContent: Self? = nil) -> AVPlayerItem {
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
