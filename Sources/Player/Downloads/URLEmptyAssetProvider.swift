//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum URLEmptyAssetProvider: URLOnlineAssetProvider {
    static func asset(from input: URLInput<EmptyCustomData>, metadata: PlayerMetadata) -> Asset {
        .simple(url: input.url)
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension URLEmptyAssetProvider: URLOfflineAssetProvider {
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: EmptyCustomData) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
