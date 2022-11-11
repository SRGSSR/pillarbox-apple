//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class AkamaiResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private var cancellable: AnyCancellable?

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        processRequest(loadingRequest)
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        processRequest(renewalRequest)
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        cancellable = nil
    }

    private func processRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let requestUrl = loadingRequest.request.url, let url = AkamaiURLCoding.decodeUrl(requestUrl) else {
            return false
        }
        cancellable = AkamaiProvider().tokenizeUrl(url)
            .sink(receiveCompletion: { _ in
                loadingRequest.finishLoading()
            }, receiveValue: { tokenizedUrl in
                loadingRequest.redirect(to: tokenizedUrl)
            })
        return true
    }
}
