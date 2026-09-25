//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(CoreBusinessPrivate)
import PillarboxCoreBusiness

import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxStandardConnector

enum DemoAssetProvider: StandardAssetLoaderProvider {
    struct Input: Codable {
        let identifier: String
        let isProduction: Bool
    }

    private struct SourceError: LocalizedError {
        var errorDescription: String? {
            String(
                localized: "No playable resources could be found.",
                comment: "Generic error message returned when no playable resources could be found"
            )
        }
    }

    static func request(for input: Input) -> URLRequest {
        let hostname = input.isProduction ? "api.pillarbox.ch" : "dev.api.pillarbox.ch"
        return URLRequest(url: URL(string: "https://\(hostname)/v1/player/media/\(input.identifier)?platform=apple")!)
    }

    static func asset(from input: Input, metadata: PlayerData<EmptyCustomData>) -> Asset {
        guard let source = metadata.source else {
            return .unavailable(with: SourceError())
        }
        if let certificateUrl = metadata.drm?.certificateUrl {
            return .encrypted(url: source.url, certificateUrl: certificateUrl)
        }
        // TODO: Akamai token protection support
        else {
            return .simple(url: source.url)
        }
    }
}

@available(tvOS, unavailable)
extension DemoAssetProvider: StandardAssetDownloadStoreProvider {
    static func id(from input: Input) -> String {
        input.identifier
    }

    static func asset(fileUrl: URL, customData: EmptyCustomData?) -> Asset {
        .simple(url: fileUrl)
    }
}
