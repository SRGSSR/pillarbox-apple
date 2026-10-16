//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension String {
    init?(localizedOptional resource: LocalizedStringResource?) {
        guard let resource else { return nil }
        self.init(localized: resource)
    }

    init?<S>(optional string: S?) where S: StringProtocol {
        guard let string else { return nil }
        self.init(string)
    }

    func unquotedComponents(separatedBy separator: Character) -> [String] {
        var components: [String] = []
        var current = ""
        var isQuoted = false
        for character in self {
            if character == "\"" {
                isQuoted.toggle()
            }
            else if character == separator && !isQuoted {
                components.append(current)
                current = ""
            }
            else {
                current.append(character)
            }
        }
        components.append(current)
        return components
    }
}
