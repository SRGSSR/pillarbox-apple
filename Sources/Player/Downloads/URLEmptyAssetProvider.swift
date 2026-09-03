//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum URLEmptyAssetProvider: URLAssetProvider {
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: EmptyCustomData) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
