//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Double {
    var toMilliseconds: Int {
        Int((self * 1000).rounded())
    }

    var toBytes: Int {
        Int((self / 8).rounded())
    }
}
