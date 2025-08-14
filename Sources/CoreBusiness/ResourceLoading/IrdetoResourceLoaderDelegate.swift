//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class IrdetoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let certificateUrl: URL

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
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
        false
    }
}
