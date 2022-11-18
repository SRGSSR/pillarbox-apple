//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVContentKeyRequest {
    func processContentKeyResponseErrorReliably(_ error: Error) {
        if let nsError = NSError.error(from: error) {
            processContentKeyResponseError(nsError)
        }
        else {
            processContentKeyResponseError(error)
        }
    }
}
