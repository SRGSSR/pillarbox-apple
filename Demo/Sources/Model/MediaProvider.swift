//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum MediaProvider: Hashable, Codable {
    case simple
    case tokenProtected
    case encrypted(certificateUrl: URL)
}
