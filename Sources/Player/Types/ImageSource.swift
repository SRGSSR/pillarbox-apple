//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import UIKit

private let kSession = URLSession(configuration: .default)

/// An image source.
public enum ImageSource: Equatable {
    /// No image.
    case none

    /// URL.
    case url(URL)

    /// Image.
    case image(UIImage)
}

extension ImageSource {
    func imageSourcePublisher() -> AnyPublisher<ImageSource, Never> {
        switch self {
        case let .url(url):
            return imageSourcePublisher(for: url)
        default:
            return Just(self).eraseToAnyPublisher()
        }
    }

    private func imageSourcePublisher(for url: URL) -> AnyPublisher<ImageSource, Never> {
        kSession.dataTaskPublisher(for: url)
            .map { data, _ in
                guard let image = UIImage(data: data) else { return .none }
                return .image(image)
            }
            .replaceError(with: .none)
            .prepend(self)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
