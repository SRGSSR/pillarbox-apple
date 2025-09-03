//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AssetContent {
    let id: UUID
    let resource: Resource
    let metadata: PlayerMetadata
    let configuration: PlaybackConfiguration
    let dateInterval: DateInterval?
    let error: Error?

    private init(id: UUID, resource: Resource, metadata: PlayerMetadata, configuration: PlaybackConfiguration, dateInterval: DateInterval?, error: Error?) {
        self.id = id
        self.resource = resource
        self.metadata = metadata
        self.configuration = configuration
        self.dateInterval = dateInterval
        self.error = error
    }

    static func loaded(id: UUID, resource: Resource, metadata: PlayerMetadata, configuration: PlaybackConfiguration, dateInterval: DateInterval?) -> Self {
        .init(id: id, resource: resource, metadata: metadata, configuration: configuration, dateInterval: dateInterval, error: nil)
    }

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading, metadata: .empty, configuration: .default, dateInterval: nil, error: nil)
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty, configuration: .default, dateInterval: nil, error: error)
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
            return playerItem(for: Resource.loading, configuration: configuration, resumeState: resumeState)
        }
        else {
            PlayerItem.load(for: id)
            return playerItem(for: resource, configuration: configuration, resumeState: resumeState)
        }
    }
}
