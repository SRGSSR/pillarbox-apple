//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer

final class IrdetoContentKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    private let certificateUrl: URL
    private let session = URLSession(configuration: .default)

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }

    private func contentKeyResponseData(for keyRequest: AVContentKeyRequest) async throws -> Data {
        let (certificateData, _) = try await session.httpData(from: certificateUrl)
        guard let identifier = keyRequest.identifier as? String else {
            throw DRMError.missingContentKeyContext
        }
        let contentKeyRequestData = try await keyRequest.makeStreamingContentKeyRequestData(
            forApp: certificateData,
            contentIdentifier: Irdeto.contentIdentifier(from: identifier)
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

    func contentKeySession(_ session: AVContentKeySession, didProvideRenewingContentKeyRequest keyRequest: AVContentKeyRequest) {
        contentKeySession(session, process: keyRequest)
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        contentKeySession(session, process: keyRequest)
    }

    private func contentKeySession(_ session: AVContentKeySession, process keyRequest: AVContentKeyRequest) {
        Task {
            do {
                let responseData = try await contentKeyResponseData(for: keyRequest)
                let response = AVContentKeyResponse(fairPlayStreamingKeyResponseData: responseData)
                keyRequest.processContentKeyResponse(response)
            } catch {
                keyRequest.processContentKeyResponseErrorReliably(error)
            }
        }
    }

    func contentKeySession(
        _ session: AVContentKeySession,
        shouldRetry keyRequest: AVContentKeyRequest,
        reason retryReason: AVContentKeyRequest.RetryReason
    ) -> Bool {
        switch retryReason {
        case .receivedObsoleteContentKey, .receivedResponseWithExpiredLease, .timedOut:
            return true
        default:
            return false
        }
    }
}
