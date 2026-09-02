//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum URLAssetProvider: AssetProvider {
    static func asset(url: URL, configuration: PlaybackConfiguration, customData: EmptyCustomData) -> Asset {
        .simple(url: url, configuration: configuration)
    }
}
