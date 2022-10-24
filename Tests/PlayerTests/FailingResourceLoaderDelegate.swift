//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

// Correct error propagation from the resource loader to the player item requires the following:
//   - The error code must be an `Int`.
//   - The error code must be different from 0.
enum ResourceLoaderError: Int, LocalizedError {
    case cannotLoadResource = 1
    case cannotRenewResource

    var errorDescription: String? {
        switch self {
        case .cannotLoadResource:
            return "Failed to load the resource (custom message)"
        case .cannotRenewResource:
            return "Failed to renew the resource (custom message)"
        }
    }
}

final class FailingResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest:
        AVAssetResourceLoadingRequest
    ) -> Bool {
        loadingRequest.finishLoading(with: ResourceLoaderError.cannotLoadResource)
        return true
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForRenewalOfRequestedResource
        renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        renewalRequest.finishLoading(with: ResourceLoaderError.cannotRenewResource)
        return true
    }
}
