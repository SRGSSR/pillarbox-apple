//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum URNAssetLoader: AssetLoader {
    struct Input: Codable {
        let urn: String
        let server: Server
        let httpHeaders: [String: String]

        var id: String {
            "\(urn)-\(server.id)"
        }
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<MediaMetadata, any Error> {
        let dataProvider = DataProvider(server: input.server)
        return dataProvider.mediaCompositionPublisher(forUrn: input.urn, httpHeaders: input.httpHeaders)
            .tryMap { response in
                try MediaMetadata(mediaCompositionResponse: response, dataProvider: dataProvider)
            }
            .eraseToAnyPublisher()
    }

    static func asset(from input: Input, metadata: MediaMetadata) -> Asset {
        if let blockingReason = metadata.blockingReason {
            return .unavailable(with: BlockingError(reason: blockingReason))
        }
        guard let resource = metadata.resource else {
            return .unavailable(with: SourceError())
        }
        let configuration = assetConfiguration(for: resource)
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

    static func playerMetadata(from input: Input, metadata: MediaMetadata?) -> PlayerMetadata {
        metadata?.playerMetadata(dateFormat: .relative) ?? .empty
    }

    private static func assetConfiguration(for resource: MediaComposition.Resource) -> PlaybackConfiguration {
        switch resource.streamType {
        case .live:
            // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
            // livestreams cannot be paused and resumed in the past, as requested by business people.
            return .init(automaticallyPreservesTimeOffsetFromLive: true, preferredForwardBufferDuration: 1)
        default:
            return .default
        }
    }
}
