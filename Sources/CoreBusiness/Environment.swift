//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Environment {
    case production
    case stage
    case test

    var url: URL {
        switch self {
        case .production:
            return URL(string: "https://il.srgssr.ch")!
        case .stage:
            return URL(string: "https://il-stage.srgssr.ch")!
        case .test:
            return URL(string: "https://il-test.srgssr.ch")!
        }
    }
}
