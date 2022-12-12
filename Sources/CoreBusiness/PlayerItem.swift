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
        if let certificateUrl = resource.drms?.first(where: { $0.type == .fairPlay })?.certificateUrl {
            return .encrypted(url: resource.url, delegate: ContentKeySessionDelegate(certificateUrl: certificateUrl))
        }
        else {
            switch resource.tokenType {
            case .akamai:
                let id = UUID()
                return .custom(
                    url: AkamaiURLCoding.encodeUrl(resource.url, id: id),
                    delegate: AkamaiResourceLoaderDelegate(id: id)
                )
            default:
                return .simple(url: resource.url)
            }
        }
    }
}
