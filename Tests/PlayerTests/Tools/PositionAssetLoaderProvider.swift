//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

struct PositionAssetLoaderProvider: URLAssetLoaderProvider {
    static func asset(from input: URLInput<Position>, metadata: AssetMetadata<Position>) -> Asset {
        .simple(url: input.url, configuration: .init(position: metadata.customData))
    }
}
