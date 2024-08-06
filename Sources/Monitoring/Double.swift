//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Double {
    var toMilliseconds: Int {
        Int(roundl(self * 1000))
    }

    var toBytes: Int {
        Int(roundl(self / 8))
    }
}
