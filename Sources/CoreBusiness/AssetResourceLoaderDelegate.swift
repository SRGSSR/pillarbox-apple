//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class AssetResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private var cancellables = [String: AnyCancellable]()

    private static func urn(from url: URL?) -> String? {
        guard let url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "urn",
              let urnQueryItem = components.queryItems?.first(where: { $0.name == "urn" }) else {
            return nil
        }
        return urnQueryItem.value
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
        guard let urn = Self.urn(from: loadingRequest.request.url) else { return }
        cancellables[urn] = nil
    }

    private func processLoadingRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let urn = Self.urn(from: loadingRequest.request.url) else { return false }
        cancellables[urn] = DataProvider().mediaComposition(forUrn: urn)
            .map(\.mainChapter.recommendedResource)
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
