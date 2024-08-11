//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URL {
    init?(string: String?) {
        guard let string else { return nil }
        self.init(string: string)
    }
}
