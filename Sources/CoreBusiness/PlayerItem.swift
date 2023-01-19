//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

public extension PlayerItem {
    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, environment: Environment = .production) {
        let publisher = DataProvider(environment: environment).recommendedPlayableResource(forUrn: urn)
            .map { Self.asset(for: $0) }
        self.init(publisher: publisher)
    }

    private static func asset(for resource: Resource) -> Asset {
        let configuration: (AVPlayerItem) -> Void = { item in
            if resource.streamType == .live {
                // Limit buffering and force the player to return to the live edge when re-buffering. This ensures
                // livestreams cannot be paused and resumed in the past, as requested by business people.
                item.automaticallyPreservesTimeOffsetFromLive = true
                item.preferredForwardBufferDuration = 1
            }
        }
        if let certificateUrl = resource.drms?.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .init(
                type: .encrypted(url: resource.url, delegate: ContentKeySessionDelegate(certificateUrl: certificateUrl)),
                metadata: nil /* TODO */,
                configuration: configuration
            )
        }
        else {
            switch resource.tokenType {
            case .akamai:
                let id = UUID()
                return .init(
                    type: .custom(url: AkamaiURLCoding.encodeUrl(resource.url, id: id), delegate: AkamaiResourceLoaderDelegate(id: id)),
                    metadata: nil /* TODO */,
                    configuration: configuration
                )
            default:
                return .init(type: .simple(url: resource.url), metadata: nil /* TODO */, configuration: configuration)
            }
        }
    }
}
