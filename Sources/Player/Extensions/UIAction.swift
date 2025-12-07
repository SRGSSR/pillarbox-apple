//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIAction {
    static func uniqueAction(title: String, image: UIImage? = nil, state: UIMenuElement.State = .off, handler: @escaping UIActionHandler) -> UIAction {
        if let image {
            return UIAction(title: title, image: image, identifier: .init(rawValue: "\(title) - \(image.hash)"), state: state, handler: handler)
        }
        else {
            return UIAction(title: title, image: image, identifier: .init(rawValue: title), state: state, handler: handler)
        }
    }
}
