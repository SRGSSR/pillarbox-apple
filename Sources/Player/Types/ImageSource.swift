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

    /// Request.
    case request(URLRequest)

    /// Image.
    case image(UIImage)
}

extension ImageSource {
    func imageSourcePublisher() -> AnyPublisher<ImageSource, Never> {
        switch self {
        case let .url(url):
            return imageSourcePublisher(for: .init(url: url))
        case let .request(request):
            return imageSourcePublisher(for: request)
        default:
            return Just(self).eraseToAnyPublisher()
        }
    }

    private func imageSourcePublisher(for request: URLRequest) -> AnyPublisher<ImageSource, Never> {
        kSession.dataTaskPublisher(for: request)
            .map { data, _ in
                guard let image = UIImage(data: data) else { return self }
                return .image(image)
            }
            .replaceError(with: self)
            .prepend(self)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
