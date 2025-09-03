//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import TCCore

extension TCAdditionalProperties {
    func addNonBlankAdditionalProperty(_ key: String, withStringValue value: String?) {
        guard let value, !value.isBlank else { return }
        addAdditionalProperty(key, withStringValue: value)
    }
}
