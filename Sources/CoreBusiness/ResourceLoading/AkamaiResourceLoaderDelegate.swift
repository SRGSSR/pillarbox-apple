//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

private enum TokenError: Error {
    case malformedParameters
}

final class AkamaiResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private static let tokenServiceUrl = URL(string: "https://tp.srgssr.ch/akahd/token")!
    private static let session = URLSession(configuration: .default)

    private let id: UUID

    init(id: UUID) {
        self.id = id
    }

    private static func acl(for url: URL) -> String {
        url.deletingLastPathComponent().appending(component: "*").path
    }

    private static func tokenRequestUrl(for url: URL) -> URL? {
        guard var components = URLComponents(url: tokenServiceUrl, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "acl", value: acl(for: url))
        ]
        return components.url
    }

    private static func mergeQueryItems(_ queryItems: [URLQueryItem], into url: URL) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        var mergedQueryItems = components.queryItems ?? []
        mergedQueryItems += queryItems
        components.queryItems = mergedQueryItems
        return components.url
    }

    private static func safeTokenizeUrl(_ url: URL) async -> URL {
        guard let tokenizedUrl = try? await tokenizeUrl(url) else { return url }
        return tokenizedUrl
    }

    private static func tokenizeUrl(_ url: URL) async throws -> URL {
        guard let requestUrl = tokenRequestUrl(for: url) else {
            throw TokenError.malformedParameters
        }
        let (data, response) = try await session.httpData(from: requestUrl)
        if let httpError = DataError.http(from: response) {
            throw httpError
        }
        guard let tokenPayload = try? JSONDecoder().decode(TokenPayload.self, from: data),
              let tokenizedUrl = mergeQueryItems(tokenPayload.token.queryItems(), into: url) else {
            throw TokenError.malformedParameters
        }
        return tokenizedUrl
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
        guard let requestUrl = loadingRequest.request.url, let url = AkamaiURLCoding.decodeUrl(requestUrl, id: id) else {
            return false
        }
        Task {
            let tokenizedUrl = await Self.safeTokenizeUrl(url)
            loadingRequest.redirect(to: tokenizedUrl)
            loadingRequest.finishLoading()
        }
        return true
    }
}
