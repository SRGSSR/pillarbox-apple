//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIMenu {
    static func identifiedMenu(title: String, subtitle: String? = nil, image: UIImage? = nil, options: UIMenu.Options = [], children: [UIMenuElement] = []) -> UIMenu? {
        guard !children.isEmpty else { return nil }
        if let image {
            return UIMenu(title: title, subtitle: subtitle, image: image, identifier: .init(rawValue: "\(title)-\(image.hash)"), options: options, children: children)
        }
        else {
            return UIMenu(title: title, subtitle: subtitle, image: image, identifier: .init(rawValue: title), options: options, children: children)
        }
    }
}
