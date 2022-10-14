//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class AssetResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let environment: Environment
    private var cancellable: AnyCancellable?

    init(environment: Environment) {
        self.environment = environment
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        processLoadingRequest(loadingRequest)
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource
        renewalRequest: AVAssetResourceRenewalRequest
    ) -> Bool {
        processLoadingRequest(renewalRequest)
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        cancellable = nil
    }

    private func processLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url, let urn = URLCoding.decodeUrn(from: url) else { return false }
        cancellable = DataProvider(environment: environment).recommendedPlayableResource(forUrn: urn)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    loadingRequest.finishLoading()
                case let .failure(error):
                    loadingRequest.finishLoading(with: error)
                }
            }, receiveValue: { resource in
                loadingRequest.redirect(to: resource.url)
            })
        return true
    }
}

private extension AVAssetResourceLoadingRequest {
    func redirect(to url: URL) {
        var redirectRequest = request
        redirectRequest.url = url
        redirect = redirectRequest
        response = HTTPURLResponse(url: url, statusCode: 303, httpVersion: nil, headerFields: nil)
    }
}
