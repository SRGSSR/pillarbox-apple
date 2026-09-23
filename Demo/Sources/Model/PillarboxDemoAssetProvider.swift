//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer
import PillarboxStandardConnector

enum DemoAssetProvider: StandardAssetLoaderProvider {
    struct Input {
        let identifier: String
        let isProduction: Bool
    }

    static func request(for input: Input) -> URLRequest {
        let hostname = input.isProduction ? "api.pillarbox.ch" : "dev.api.pillarbox.ch"
        return URLRequest(url: URL(string: "https://\(hostname)/v1/player/media/\(input.identifier)?platform=apple")!)
    }

    static func asset(from input: Input, metadata: PlayerData<EmptyCustomData>) -> Asset {
        .simple(url: metadata.source!.url)
    }
}
