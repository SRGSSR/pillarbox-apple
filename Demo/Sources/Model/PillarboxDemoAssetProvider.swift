//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxStandardConnector

enum DemoAssetProvider: StandardAssetLoaderProvider {
    struct Input: Codable {
        let identifier: String
        let isProduction: Bool
    }

    private struct SourceError: Error {}

    static func request(for input: Input) -> URLRequest {
        let hostname = input.isProduction ? "api.pillarbox.ch" : "dev.api.pillarbox.ch"
        return URLRequest(url: URL(string: "https://\(hostname)/v1/player/media/\(input.identifier)?platform=apple")!)
    }

    static func asset(from input: Input, metadata: PlayerData<EmptyCustomData>) -> Asset {
        if let source = metadata.source {
            .simple(url: source.url)
        }
        else {
            .unavailable(with: SourceError())
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
