//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension String {
    /// The source key for apps in production.
    static let productionSourceKey = "1b30366c-9e8d-4720-8b12-4165f468f9ae"

    /// The source key for apps in development.
    static let developmentSourceKey = "39ae8f94-595c-4ca4-81f7-fb7748bd3f04"
}

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
