//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URLSession {
    /// Convenience method to load data using an URLRequest, creates and resumes an `URLSessionDataTask` internally.
    /// Same as `data(for:delegate:)` but throwing HTTP errors when encountered.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    func httpData(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        let (data, response) = try await data(for: request)
        if let httpError = DataError.http(from: response) {
            throw httpError
        }
        return (data, response)
    }

    /// Convenience method to load data using an URL, creates and resumes an `URLSessionDataTask` internally. Same
    /// as `data(from:delegate:)` but throwing HTTP errors when encountered.
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: Data and response.
    func httpData(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        let (data, response) = try await data(from: url)
        if let httpError = DataError.http(from: response) {
            throw httpError
        }
        return (data, response)
    }
}

