//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

// swiftlint:disable missing_docs

public enum URNAssetLoader: AssetLoader {
    public struct Input {
        let urn: String
        let server: Server
        let configuration: PlaybackConfiguration

        public init(urn: String, server: Server, configuration: PlaybackConfiguration) {
            self.urn = urn
            self.server = server
            self.configuration = configuration
        }
    }

    public static func metadataPublisher(for input: Input) -> AnyPublisher<MediaMetadata, any Error> {
        let dataProvider = DataProvider(server: input.server)
        return dataProvider.mediaCompositionPublisher(forUrn: input.urn)
            .tryMap { response in
                try MediaMetadata(mediaCompositionResponse: response, dataProvider: dataProvider)
            }
            .eraseToAnyPublisher()
    }

    public static func asset(from input: Input, metadata: MediaMetadata) -> Asset {
        if let blockingReason = metadata.blockingReason {
            return .unavailable(with: BlockingError(reason: blockingReason))
        }
        guard let resource = metadata.resource else {
            return .unavailable(with: SourceError())
        }
        let configuration = assetConfiguration(for: resource, configuration: input.configuration)
        if let certificateUrl = resource.drms.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .encrypted(url: resource.url, certificateUrl: certificateUrl, configuration: configuration)
        }
        else {
            switch resource.tokenType {
            case .akamai:
                return .tokenProtected(url: resource.url, configuration: configuration)
            default:
                return .simple(url: resource.url, configuration: configuration)
            }
        }
    }

    public static func playerMetadata(from input: Input, metadata: MediaMetadata?) -> PlayerMetadata {
        metadata?.playerMetadata() ?? .empty
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

// swiftlint:enable missing_docs
