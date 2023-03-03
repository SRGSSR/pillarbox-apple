//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

let kPageSize: UInt = 50

func constant<T>(iOS: T, tvOS: T) -> T {
#if os(tvOS)
    return tvOS
#else
    return iOS
#endif
}
