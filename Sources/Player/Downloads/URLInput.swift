//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Foundation

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct URLInput<CustomData> {
    let url: URL
    let metadata: AssetMetadata<CustomData>
}

// swiftlint:enable missing_docs
