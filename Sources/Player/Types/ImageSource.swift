//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import UIKit

public enum ImageSource: Equatable {
    case none
    case url(URL)
    case request(URLRequest)
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
        URLSession.shared.dataTaskPublisher(for: request)
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
