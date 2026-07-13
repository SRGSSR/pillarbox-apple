//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@available(tvOS, unavailable)
struct DownloadPhase<Result, CustomData> {
    let result: Result
    let assetMetadata: AssetMetadata<CustomData>
}

#endif
