//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct HttpResponseHandler {
    let data: Data?
    let response: URLResponse?
    let error: Error?
}

class URLProtocolMock: URLProtocol {
    static var responseHandler: ((URLRequest) -> HttpResponseHandler)?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let responseHandler = Self.responseHandler?(request) else { return }
        if let response = responseHandler.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = responseHandler.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = responseHandler.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
