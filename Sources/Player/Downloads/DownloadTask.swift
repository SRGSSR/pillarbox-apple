//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadTask<CustomData> {
    let wrappedValue: URLSessionTask?
    let assetMetadata: AssetMetadata<CustomData>

    init(_ wrappedValue: URLSessionTask?, assetMetadata: AssetMetadata<CustomData>) {
        self.wrappedValue = wrappedValue
        self.assetMetadata = assetMetadata
    }
}

#endif
