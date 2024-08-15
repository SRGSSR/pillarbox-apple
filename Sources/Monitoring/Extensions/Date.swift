//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Date {
    var timestamp: Int {
        Int((timeIntervalSince1970 * 1000).rounded())
    }
}
