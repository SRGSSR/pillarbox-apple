//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import os
import PillarboxPlayer

final class ContentKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    private static let logger = Logger(category: "ContentKeySessionDelegate")

    private let certificateUrl: URL
    private let session = URLSession(configuration: .default)

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }

    private static func contentKeyContextRequest(from identifier: Any?, httpBody: Data) -> URLRequest? {
        guard let skdUrlString = identifier as? String,
              var components = URLComponents(string: skdUrlString) else {
            return nil
        }

        components.scheme = "https"
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = httpBody
        return request
    }

    private func contentKeyResponseData(for keyRequest: AVContentKeyRequest) async throws -> Data {
        let (certificateData, _) = try await session.httpData(from: certificateUrl)
        let contentKeyRequestData = try await keyRequest.makeStreamingContentKeyRequestData(
            forApp: certificateData,
            contentIdentifier: contentIdentifier(from: keyRequest)
        )
        guard let contentKeyContextRequest = Self.contentKeyContextRequest(
            from: keyRequest.identifier,
            httpBody: contentKeyRequestData
        ) else {
            throw DRMError.missingContentKeyContext
        }
        let (contentKeyContextData, _) = try await session.httpData(for: contentKeyContextRequest)
        return contentKeyContextData
    }

    func contentKeySession(_ session: AVContentKeySession, didProvideRenewingContentKeyRequest keyRequest: AVContentKeyRequest) {
        Self.logger.info("--> didProvideRenewingContentKeyRequest: \(keyRequest)")
        contentKeySession(session, process: keyRequest)
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        Self.logger.info("--> didProvide: \(keyRequest)")
        contentKeySession(session, process: keyRequest)
    }

    func contentKeySession(_ session: AVContentKeySession, shouldRetry keyRequest: AVContentKeyRequest, reason retryReason: AVContentKeyRequest.RetryReason) -> Bool {
        switch retryReason {
        case .timedOut:
            Self.logger.info("--> shouldRetry and will (timeout) for: \(keyRequest)")
            return true
        case .receivedResponseWithExpiredLease:
            Self.logger.info("--> shouldRetry and will (expired lease) for: \(keyRequest)")
            return true
        case .receivedObsoleteContentKey:
            Self.logger.info("--> shouldRetry and will (obsolete) for: \(keyRequest)")
            return true
        default:
            Self.logger.info("--> shouldRetry but won't (other: \(retryReason.rawValue) for: \(keyRequest)")
            return false
        }
    }

    func contentKeySession(_ session: AVContentKeySession, contentKeyRequest keyRequest: AVContentKeyRequest, didFailWithError err: any Error) {
        Self.logger.info("--> didFail for: \(keyRequest) with \(err)")
    }

    func contentKeySession(_ session: AVContentKeySession, contentKeyRequestDidSucceed keyRequest: AVContentKeyRequest) {
        Self.logger.info("--> didSuceeed for: \(keyRequest)")
    }

    func contentKeySessionDidGenerateExpiredSessionReport(_ session: AVContentKeySession) {
        Self.logger.info("--> didGenerateExpiredSessionReport")
    }

    func contentKeySessionContentProtectionSessionIdentifierDidChange(_ session: AVContentKeySession) {
        Self.logger.info("--> protectionSessionIdentifierDidChange")
    }

    func contentKeySession(_ session: AVContentKeySession, externalProtectionStatusDidChangeFor contentKey: AVContentKey) {
        Self.logger.info("--> externalProtectionStatusDidChangeFor for \(contentKey)")
    }

    private func contentKeySession(_ session: AVContentKeySession, process keyRequest: AVContentKeyRequest) {
        Task {
            do {
                let responseData = try await contentKeyResponseData(for: keyRequest)
                let response = AVContentKeyResponse(fairPlayStreamingKeyResponseData: responseData)
                keyRequest.processContentKeyResponse(response)
                Self.logger.info("--> processContentKeyResponse with \(response)")
            } catch {
                Self.logger.info("--> processContentKeyResponseError with \(error)")
                keyRequest.processContentKeyResponseErrorReliably(error)
            }
        }
    }

    private func contentIdentifier(from keyRequest: AVContentKeyRequest) -> Data? {
        guard let identifier = keyRequest.identifier as? String,
              let components = URLComponents(string: identifier),
              let contentIdentifier = components.queryItems?.first(where: { $0.name == "contentId" })?.value else {
            return nil
        }
        Self.logger.info("--> content identifier: \(contentIdentifier)")
        return Data(contentIdentifier.utf8)
    }
}
