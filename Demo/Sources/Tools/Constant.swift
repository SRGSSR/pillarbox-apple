//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

let kPageSize: UInt = 50

extension Animation {
    static let defaultLinear = linear(duration: 0.2)
}

func constant<T>(iOS: T, tvOS: T) -> T {
#if os(tvOS)
    tvOS
#else
    iOS
#endif
}
