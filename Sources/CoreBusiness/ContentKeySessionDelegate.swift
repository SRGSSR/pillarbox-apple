//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Player

final class ContentKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    private let certificateUrl: URL
    private let session = URLSession(configuration: .default)
    private var cancellable: AnyCancellable?

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }

    private static func contentKeyRequestDataPublisher(for request: AVContentKeyRequest, certificateData: Data) -> AnyPublisher<Data, Error> {
        Future { promise in
            // Use a dummy content identifier (otherwise the request will fail).
            request.makeStreamingContentKeyRequestData(forApp: certificateData, contentIdentifier: "content_id".data(using: .utf8)) { data, error in
                if let data {
                    promise(.success(data))
                }
                else if let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
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

    private static func contentKeyContextDataPublisher(fromKeyRequestData keyRequestData: Data, identifier: Any?, session: URLSession) -> AnyPublisher<Data, Error> {
        guard let request = contentKeyContextRequest(from: identifier, httpBody: keyRequestData) else {
            return Fail(error: DRMError.missingContentKeyContext)
                .eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: request)
            .mapError { $0 }
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        cancellable = self.session.dataTaskPublisher(for: certificateUrl)
            .mapError { $0 }
            .map { Self.contentKeyRequestDataPublisher(for: keyRequest, certificateData: $0.data) }
            .switchToLatest()
            .map { [session = self.session] data in
                Self.contentKeyContextDataPublisher(fromKeyRequestData: data, identifier: keyRequest.identifier, session: session)
            }
            .switchToLatest()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    keyRequest.processContentKeyResponseErrorReliably(error)
                }
            } receiveValue: { data in
                let response = AVContentKeyResponse(fairPlayStreamingKeyResponseData: data)
                keyRequest.processContentKeyResponse(response)
            }
    }
}
