//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class FailingResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    // Correct error propagation from the resource loader to the player item requires the following:
    //   - The error code must be an `Int`.
    //   - The error code must be different from 0.
    enum PlaybackError: Int, LocalizedError {
        case cannotLoadResource = 1
        case cannotRenewResource = 2

        var errorDescription: String? {
            switch self {
            case .cannotLoadResource:
                return "Failed to load the resource (custom message)"
            case .cannotRenewResource:
                return "Failed to renew the resource (custom message)"
            }
        }
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        loadingRequest.finishLoading(with: PlaybackError.cannotLoadResource)
        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        renewalRequest.finishLoading(with: PlaybackError.cannotRenewResource)
        return true
    }
}
