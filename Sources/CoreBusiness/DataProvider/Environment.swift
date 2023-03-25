//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Environment.
public enum Environment {
    /// Production.
    case production
    /// State.
    case stage
    /// Test.
    case test

    internal var url: URL {
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
