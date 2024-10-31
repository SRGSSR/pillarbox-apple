//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore
import UIKit

private enum TriggerId {
    case load
}

private let kSession = URLSession(configuration: .default)

/// An image source.
public struct ImageSource: Equatable {
    enum Kind: Equatable {
        case none
        case url(URL, constrainedNetworkUrl: URL)
        case image(UIImage)
    }

    /// No image.
    public static let none = Self(kind: .none)

    let kind: Kind
    private let trigger = Trigger()

    /// URL.
    public static func url(_ url: URL, constrainedNetworkUrl: URL? = nil) -> Self {
        Self(kind: .url(url, constrainedNetworkUrl: constrainedNetworkUrl ?? url))
    }

    /// Image.
    public static func image(_ image: UIImage) -> Self {
        Self(kind: .image(image))
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.kind == rhs.kind
    }
}

extension ImageSource {
    var image: UIImage? {
        switch kind {
        case let .image(image):
            return image
        case .url:
            trigger.activate(for: TriggerId.load)
            return nil
        default:
            return nil
        }
    }

    func imageSourcePublisher() -> AnyPublisher<ImageSource, Never> {
        switch kind {
        case let .url(url, constrainedNetworkUrl: constrainedNetworkUrl):
            return imageSourcePublisher(for: url, constrainedNetworkUrl: constrainedNetworkUrl)
        default:
            return Just(self).eraseToAnyPublisher()
        }
    }

    private func imageSourcePublisher(for url: URL, constrainedNetworkUrl: URL) -> AnyPublisher<ImageSource, Never> {
        var request = URLRequest(url: url)
        request.allowsConstrainedNetworkAccess = false
        return kSession.dataTaskPublisher(for: request)
            .wait(untilOutputFrom: trigger.signal(activatedBy: TriggerId.load))
            .tryCatch { error in
                guard error.networkUnavailableReason == .constrained else {
                    throw error
                }
                return kSession.dataTaskPublisher(for: constrainedNetworkUrl).eraseToAnyPublisher()
            }
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
