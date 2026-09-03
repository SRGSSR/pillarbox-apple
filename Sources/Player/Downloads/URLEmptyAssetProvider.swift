//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// swiftlint:disable missing_docs

public enum URLEmptyAssetProvider: URLAssetProvider {
    public static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: EmptyCustomData) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}

// swiftlint:enable missing_docs
