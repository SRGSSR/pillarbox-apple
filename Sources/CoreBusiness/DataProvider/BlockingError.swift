//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Blocking error.
public struct BlockingError: LocalizedError {
    /// A reason.
    public let reason: BlockingReason

    /// A readable error description.
    public let errorDescription: String?

    init(reason: BlockingReason) {
        self.reason = reason
        self.errorDescription = reason.description
    }
}
