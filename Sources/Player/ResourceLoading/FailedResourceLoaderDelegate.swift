//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class FailedResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        loadingRequest.finishLoadingReliably(with: error)
        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        renewalRequest.finishLoadingReliably(with: error)
        return true
    }
}
