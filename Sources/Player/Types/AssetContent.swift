//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxCore

struct AssetContent {
    let id: UUID
    let resource: Resource
    let metadata: PlayerMetadata
    let configuration: PlaybackConfiguration
    let service: ClockInterval<SuspendingClock>?

    private init(id: UUID, resource: Resource, metadata: PlayerMetadata, configuration: PlaybackConfiguration, service: ClockInterval<SuspendingClock>?) {
        self.id = id
        self.resource = resource
        self.metadata = metadata
        self.configuration = configuration
        self.service = service
    }

    static func loaded(
        id: UUID,
        resource: Resource,
        metadata: PlayerMetadata,
        configuration: PlaybackConfiguration,
        service: ClockInterval<SuspendingClock>?
    ) -> Self {
        .init(id: id, resource: resource, metadata: metadata, configuration: configuration, service: service)
    }

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading(), metadata: .empty, configuration: .default, service: nil)
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty, configuration: .default, service: nil)
    }

    private func playerItem(for resource: Resource, configuration: PlayerConfiguration, resumeState: ResumeState?) -> AVPlayerItem {
        let item = resource.playerItem(configuration: configuration)
            .withId(id)
            .updated(with: self)
        self.configuration.apply(to: item, metadata: metadata, resumeState: resumeState)
        return item
    }

    func playerItem(reload: Bool, configuration: PlayerConfiguration, resumeState: ResumeState?) -> AVPlayerItem {
        if reload, resource.isFailing {
            PlayerItem.reload(for: id)
            return playerItem(for: Resource.loading(), configuration: configuration, resumeState: resumeState)
        }
        else {
            PlayerItem.load(for: id)
            return playerItem(for: resource, configuration: configuration, resumeState: resumeState)
        }
    }
}
