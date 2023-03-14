//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Bundle {
    static var test: Bundle {
        let path = Bundle(for: StreamTypeTests.self).path(forResource: "Pillarbox_PlayerTests", ofType: "bundle")!
        return Bundle(path: path)!
    }
}
