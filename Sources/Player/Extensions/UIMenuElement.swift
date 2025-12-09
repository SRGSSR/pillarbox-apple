//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIMenuElement {
    var isNestedMenu: Bool {
        guard let menu = self as? UIMenu else { return false }
        return !menu.options.contains(.displayInline)
    }
}
