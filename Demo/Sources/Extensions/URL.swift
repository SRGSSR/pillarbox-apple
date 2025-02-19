//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URL: @retroactive ExpressibleByStringLiteral {
    // swiftlint:disable:next missing_docs
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)!
    }
}
