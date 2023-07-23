//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVAssetResourceLoadingRequest {
    /// Causes the receiver to handle the failure to load a resource for which a resource loader’s delegate took
    /// responsibility.
    ///
    /// - Parameter error: An error object indicating the reason for the failure.
    ///
    /// Unlike `finishLoading(with:)` this method ensures error information can be reliably forwarded to the player
    /// item being loaded in case of failure.
    func finishLoadingReliably(with error: Error?) {
        finishLoading(with: NSError.error(from: error))
    }

    /// Redirects the receiver to another URL.
    /// 
    /// - Parameter url: The URL to redirect the receiver to.
    func redirect(to url: URL) {
        var redirectRequest = request
        redirectRequest.url = url
        redirect = redirectRequest
        response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
    }
}
