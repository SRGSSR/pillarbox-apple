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
///
/// An image source is opaque and not meant for direct image extraction. To display an image from a source, use
/// ``LazyImage`` in SwiftUI or ``LazyUIImage(source:)`` in UIKit.
public struct ImageSource: Equatable {
    enum Kind: Equatable {
        case none
        case url(standardResolution: URL, lowResolution: URL)
        case image(UIImage)
    }

    /// No image.
    public static let none = Self(kind: .none)

    let kind: Kind
    private let trigger = Trigger()

    /// An image retrieved from a URL.
    ///
    /// - Parameters:
    ///   - standardResolutionUrl: The URL where a variant with standard resolution can be retrieved.
    ///   - lowResolutionUrl: The URL where a variant with low resolution can be retrieved when Low Data Mode has been
    ///     enabled. If omitted the standard resolution URL is used.
    public static func url(standardResolution standardResolutionUrl: URL, lowResolution lowResolutionUrl: URL? = nil) -> Self {
        Self(kind: .url(standardResolution: standardResolutionUrl, lowResolution: lowResolutionUrl ?? standardResolutionUrl))
    }

    /// Image.
    public static func image(_ image: UIImage) -> Self {
        Self(kind: .image(image))
    }

    // swiftlint:disable:next missing_docs
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
        case let .url(standardResolution: standardResolutionUrl, lowResolution: lowResolutionUrl):
            return imageSourcePublisher(forStandardResolutionUrl: standardResolutionUrl, lowResolutionUrl: lowResolutionUrl)
        default:
            return Just(self).eraseToAnyPublisher()
        }
    }

    private func imageSourcePublisher(
        forStandardResolutionUrl standardResolutionUrl: URL,
        lowResolutionUrl: URL
    ) -> AnyPublisher<ImageSource, Never> {
        var request = URLRequest(url: standardResolutionUrl)
        request.allowsConstrainedNetworkAccess = false
        return kSession.dataTaskPublisher(for: request)
            .wait(untilOutputFrom: trigger.signal(activatedBy: TriggerId.load))
            .tryCatch { error in
                guard error.networkUnavailableReason == .constrained else {
                    throw error
                }
                return kSession.dataTaskPublisher(for: lowResolutionUrl)
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
