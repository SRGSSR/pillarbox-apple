//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import UIKit

struct ImageCatalog {
    let images: [String: UIImage]
    let width: DataProvider.ImageWidth

    lazy var placeholderImage: UIImage = {
        .image(with: .darkGray, width: CGFloat(width.rawValue))
    }()

    func image(for identifier: String) -> UIImage? {
        images[identifier]
    }
}
