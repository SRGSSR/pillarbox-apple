//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ResourceLoaderError: Error {
    let errorDescription: String?
}

final class FailingResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        let error = ResourceLoaderError(errorDescription: "Failed to load the resource (custom message)")
        loadingRequest.finishLoadingReliably(with: error)
        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        let error = ResourceLoaderError(errorDescription: "Failed to renew the resource (custom message)")
        renewalRequest.finishLoadingReliably(with: error)
        return true
    }
}
