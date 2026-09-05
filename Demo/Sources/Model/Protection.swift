//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Protection: Hashable, Codable {
    case none
    case token
    case fairPlay(certificateUrl: URL)
}
