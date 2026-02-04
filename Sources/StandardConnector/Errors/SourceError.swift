//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Source error.
public struct SourceError: LocalizedError {
    /// A readable error description.
    public var errorDescription: String? {
        String(
            localized: "No playable resources could be found.",
            bundle: .module,
            comment: "Generic error message returned when no playable resources could be found"
        )
    }

    @_spi(StandardConnectorPrivate)
    public init() {
        // swiftlint:disable:previous missing_docs
    }
}
