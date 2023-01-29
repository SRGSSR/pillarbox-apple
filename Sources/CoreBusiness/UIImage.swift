//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import UIKit

// ✋🏾 Ask Sam: Is CoreBusiness the right location ?
extension UIImage {
    /// A publisher which delivers an UIImage.
    /// - Parameter url: The url of the image.
    /// - Returns: A publisher that wraps an UIImage or empty UIImage if the tasks fails.
    static func imagePublisher(from url: String) -> AnyPublisher<UIImage, Never> {
        guard let url = URL(string: url) else { return Just(UIImage()).eraseToAnyPublisher() }

        return URLSession(configuration: .default)
            .dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .replaceError(with: UIImage())
            .eraseToAnyPublisher()
    }
}
