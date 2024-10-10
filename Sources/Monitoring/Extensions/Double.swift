//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension Double {
    var toMilliseconds: Int {
        Int((self * 1000).rounded())
    }
}
