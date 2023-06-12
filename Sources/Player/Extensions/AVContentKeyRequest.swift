//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVContentKeyRequest {
    /// Informs the receiver that obtaining a content key response has failed, resulting in failure handling.
    ///
    /// - Parameter error: An error object indicating the reason for the failure.
    ///
    /// Unlike `processContentKeyResponseError(_:)` this method ensures error information can be reliably
    /// forwarded to the player item being loaded in case of failure.
    func processContentKeyResponseErrorReliably(_ error: Error) {
        if let nsError = NSError.error(from: error) {
            processContentKeyResponseError(nsError)
        }
        else {
            processContentKeyResponseError(error)
        }
    }
}
