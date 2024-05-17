//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer

final class ContentKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
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
            contentIdentifier: Data("content_id".utf8 )
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

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
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
}
