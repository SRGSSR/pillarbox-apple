//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A server environment.
public enum Server {
    /// Production.
    case production

    /// Stage.
    case stage

    /// Test.
    case test

    /// MMF.
    case mmf

    var url: URL {
        switch self {
        case .production:
            return URL(string: "https://il.srgssr.ch")!
        case .stage:
            return URL(string: "https://il-stage.srgssr.ch")!
        case .test:
            return URL(string: "https://il-test.srgssr.ch")!
        case .mmf:
            return URL(string: "https://play-mmf.herokuapp.com")!
        }
    }
}
