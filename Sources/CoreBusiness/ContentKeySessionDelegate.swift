//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class ContentKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    private let certificateUrl: URL
    private let session = URLSession(configuration: .default)
    private var cancellable: AnyCancellable?

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        cancellable = self.session.dataTaskPublisher(for: certificateUrl)
            .mapError { $0 /* Convert error type */ }
            .map { Self.contentKeyRequestDataPublisher(for: keyRequest, data: $0.data) }
            .switchToLatest()
            .sink { completion in
                print("--> completion: \(completion)")
            } receiveValue: { value in
                print("--> value: \(value)")
            }
    }

    static func contentKeyRequestDataPublisher(for request: AVContentKeyRequest, data: Data) -> AnyPublisher<Data, Error> {
        return Future { promise in
            request.makeStreamingContentKeyRequestData(forApp: data, contentIdentifier: nil) { data, error in
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
}
