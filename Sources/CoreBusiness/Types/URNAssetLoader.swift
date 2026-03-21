//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

enum URNAssetLoader: AssetLoader {
    struct Input {
        let urn: String
        let server: Server
        let configuration: PlaybackConfiguration
    }

    static func publisher(for input: Input) -> AnyPublisher<Asset<MediaMetadata>, Error> {
        let dataProvider = DataProvider(server: input.server)
        return dataProvider.mediaCompositionPublisher(forUrn: input.urn)
            .tryMap { response in
                let metadata = try MediaMetadata(mediaCompositionResponse: response, dataProvider: dataProvider)
                return Self.asset(metadata: metadata, configuration: input.configuration, dataProvider: dataProvider)
            }
            .eraseToAnyPublisher()
    }

    static func playerMetadata(from metadata: MediaMetadata) -> PlayerMetadata {
        metadata.playerMetadata()
    }
}

private extension URNAssetLoader {
    private static func asset(metadata: MediaMetadata, configuration: PlaybackConfiguration, dataProvider: DataProvider) -> Asset<MediaMetadata> {
        if let blockingReason = metadata.blockingReason {
            return .unavailable(with: BlockingError(reason: blockingReason), metadata: metadata)
        }
        guard let resource = metadata.resource else {
            return .unavailable(with: SourceError(), metadata: metadata)
        }
        let configuration = assetConfiguration(for: resource, configuration: configuration)
        if let certificateUrl = resource.drms.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .encrypted(url: resource.url, certificateUrl: certificateUrl, metadata: metadata, configuration: configuration)
        }
        else {
            switch resource.tokenType {
            case .akamai:
                return .tokenProtected(url: resource.url, metadata: metadata, configuration: configuration)
            default:
                return .simple(url: resource.url, metadata: metadata, configuration: configuration)
            }
        }
    }

    private static func assetConfiguration(
        for resource: MediaComposition.Resource,
        configuration: PlaybackConfiguration
    ) -> PlaybackConfiguration {
        // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
        // livestreams cannot be paused and resumed in the past, as requested by business people.
        guard resource.streamType == .live else { return configuration }
        return .init(automaticallyPreservesTimeOffsetFromLive: true, preferredForwardBufferDuration: 1)
    }
}
