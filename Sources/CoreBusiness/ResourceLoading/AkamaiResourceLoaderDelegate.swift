//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class AkamaiResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private static let session = URLSession(configuration: .default)

    private let id: UUID

    init(id: UUID) {
        self.id = id
    }

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

    private func processRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let requestUrl = loadingRequest.request.url, let url = Akamai.decodeUrl(requestUrl, id: id) else {
            return false
        }
        Task {
            let tokenizedUrl = await Akamai.tokenizeUrl(url, using: Self.session)
            loadingRequest.redirect(to: tokenizedUrl)
            loadingRequest.finishLoading()
        }
        return true
    }
}
