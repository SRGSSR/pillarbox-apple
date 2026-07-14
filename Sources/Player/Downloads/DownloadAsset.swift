//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@available(tvOS, unavailable)
struct DownloadAsset<CustomData> {
    let wrappedValue: Asset
    let assetMetadata: AssetMetadata<CustomData>

    init(_ wrappedValue: Asset, assetMetadata: AssetMetadata<CustomData>) {
        self.wrappedValue = wrappedValue
        self.assetMetadata = assetMetadata
    }
}
