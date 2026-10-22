//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum URI {
    static func dataUri(for data: Data) -> String {
        "data:application/octet-stream;base64,\(data.base64EncodedString())"
    }
}
