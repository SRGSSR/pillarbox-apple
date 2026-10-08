//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIAction {
    static func identifiedAction(
        title: String,
        subtitle: String? = nil,
        image: UIImage? = nil,
        state: UIMenuElement.State = .off,
        handler: @escaping UIActionHandler
    ) -> UIAction {
        if let image {
            return UIAction(
                title: title,
                subtitle: subtitle,
                image: image,
                identifier: .init(rawValue: "\(title)-\(image.hash)"),
                state: state,
                handler: handler
            )
        }
        else {
            return UIAction(title: title, subtitle: subtitle, image: image, identifier: .init(rawValue: title), state: state, handler: handler)
        }
    }
}
