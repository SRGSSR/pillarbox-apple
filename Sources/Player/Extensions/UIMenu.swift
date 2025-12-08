//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIMenu {
    static func identifiableMenu(title: String, image: UIImage? = nil, options: UIMenu.Options = [], children: [UIMenuElement] = []) -> UIMenu {
        if let image {
            return UIMenu(title: title, image: image, identifier: .init(rawValue: "\(title) - \(image.hash)"), options: options, children: children)
        }
        else {
            return UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: options, children: children)
        }
    }
}
