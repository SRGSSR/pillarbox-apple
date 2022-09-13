//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreBusiness
import Foundation

enum MediaSource: Hashable {
    case url(URL)
    case urn(String)

    var playerItem: AVPlayerItem {
        switch self {
        case let .url(url):
            return AVPlayerItem(url: url)
        case let .urn(urn):
            return AVPlayerItem(urn: urn)
        }
    }
}
