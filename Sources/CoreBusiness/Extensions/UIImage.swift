//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIImage {
    static func image(with color: UIColor, width: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: width * 9 / 16)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
