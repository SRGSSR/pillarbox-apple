//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public enum URLEmptyAssetProvider: URLOfflineAssetProvider {
    public static func asset(from input: URLInput<EmptyCustomData>, metadata: PlayerMetadata) -> Asset {
        .simple(url: input.url)
    }

    public static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: EmptyCustomData) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
