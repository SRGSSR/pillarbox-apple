//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVAssetResourceLoadingRequest {
     func redirect(to url: URL) {
         var redirectRequest = request
         redirectRequest.url = url
         redirect = redirectRequest
         response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
     }
 }
