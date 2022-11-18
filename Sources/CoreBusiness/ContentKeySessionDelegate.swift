//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class ContentKeySessionDelegate: NSObject, AVContentKeySessionDelegate {
    private let certificateUrl: URL

    init(certificateUrl: URL) {
        self.certificateUrl = certificateUrl
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        print("-->")
    }
}
