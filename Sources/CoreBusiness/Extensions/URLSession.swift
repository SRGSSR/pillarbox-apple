//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URLSession {
    /// Loads data for a request, throwing when HTTP errors are encountered.
    ///
    /// - Parameters:
    ///   - request: The request for which to load data.
    ///   - delegate: The task-specific delegate to use.
    /// - Returns: Data and response.
    func httpData(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        let (data, response) = try await data(for: request, delegate: delegate)
        if let httpError = HttpError(response: response) {
            throw httpError
        }
        return (data, response)
    }

    /// Loads data for a URL, throwing when HTTP errors are encountered.
    ///
    /// - Parameters:
    ///   - url: The URL for which to load data.
    ///   - delegate: The task-specific delegate to use.
    /// - Returns: Data and response.
    func httpData(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        let (data, response) = try await data(from: url, delegate: delegate)
        if let httpError = HttpError(response: response) {
            throw httpError
        }
        return (data, response)
    }
}
