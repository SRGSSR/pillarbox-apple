//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class IrdetoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let certificateUrl: URL
    private let session = URLSession(configuration: .default)

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }

    private func contentKeyResponseData(for loadingRequest: AVAssetResourceLoadingRequest) async throws -> Data {
        let (certificateData, _) = try await session.httpData(from: certificateUrl)
        guard let identifier = loadingRequest.request.url?.absoluteString,
              let contentIdentifier = Irdeto.contentIdentifier(from: identifier) else {
            throw DRMError.missingContentKeyContext
        }
        let contentKeyRequestData = try loadingRequest.streamingContentKeyRequestData(
          forApp: certificateData,
          contentIdentifier: contentIdentifier
        )
        guard let contentKeyContextRequest = Irdeto.contentKeyContextRequest(
            from: identifier,
            httpBody: contentKeyRequestData
        ) else {
            throw DRMError.missingContentKeyContext
        }
        let (contentKeyContextData, _) = try await session.httpData(for: contentKeyContextRequest)
        return contentKeyContextData
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
        Task {
            do {
                let responseData = try await contentKeyResponseData(for: loadingRequest)
                loadingRequest.dataRequest?.respond(with: responseData)
                loadingRequest.finishLoading()
            } catch {
                loadingRequest.finishLoadingReliably(with: error)
            }
        }
        return true
    }
}
