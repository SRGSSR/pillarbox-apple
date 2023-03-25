//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVAssetResourceLoadingRequest {
    /// Causes the receiver to handle the failure to load a resource for which a resource loader’s delegate took
    /// responsibility. Unlike `finishLoading(with:)` this method ensures error information can be reliably
    /// forwarded to the player item being loaded in case of failure.
    /// - Parameter error: An error object indicating the reason for the failure.
    func finishLoadingReliably(with error: Error?) {
        let nsError = NSError.error(from: error)
        if let nsError {
            assert(nsError.code != 0, "An error must have a code != 0 to be properly returned by the resource loader")
        }
        finishLoading(with: nsError)
    }

    /// Redirect the receiver to another URL.
    /// - Parameter url: The URL to redirect the receiver to.
    func redirect(to url: URL) {
        var redirectRequest = request
        redirectRequest.url = url
        redirect = redirectRequest
        response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
    }
}
