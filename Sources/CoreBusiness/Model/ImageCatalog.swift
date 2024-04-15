//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import UIKit

struct ImageCatalog {
    static var placeholderImages: [DataProvider.ImageWidth: UIImage] = [:]

    let images: [String: UIImage]
    let width: DataProvider.ImageWidth

    private let lock = NSRecursiveLock()

    func image(for identifier: String) -> UIImage? {
        images[identifier]
    }

    func placeholderImage() -> UIImage {
        lock.lock()
        defer { lock.unlock() }

        if let placeholderImage = Self.placeholderImages[width] {
            return placeholderImage
        }
        let placeholderImage = UIImage.image(color: .darkGray, width: CGFloat(width.rawValue))
        Self.placeholderImages[width] = placeholderImage
        return placeholderImage
    }
}
