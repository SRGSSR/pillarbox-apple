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
public struct ImageSource: Codable, Equatable {
    enum Kind: Codable, Equatable {
        case none
        case url(standardResolution: URL, lowResolution: URL)
        case image(Data)
    }

    private enum CodingKeys: String, CodingKey {
        case kind
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
        Self(kind: kind(from: image))
    }

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.kind == rhs.kind
    }

    private static func kind(from image: UIImage) -> Kind {
        guard let data = image.pngData() else { return .none }
        return .image(data)
    }
}

extension ImageSource {
    var image: UIImage? {
        switch kind {
        case let .image(data):
            return UIImage(data: data)
        default:
            return nil
        }
    }

    @discardableResult
    func fetchImage() -> UIImage? {
        switch kind {
        case let .image(data):
            return UIImage(data: data)
        case .url:
            trigger.activate(for: TriggerId.load)
            return nil
        default:
            return nil
        }
    }
}

extension ImageSource {
    func lazyImageSourcePublisher() -> AnyPublisher<ImageSource, Never> {
        guard case let .url(standardResolution: standardResolutionUrl, lowResolution: lowResolutionUrl) = kind else {
            return Just(self).eraseToAnyPublisher()
        }
        var request = URLRequest(url: standardResolutionUrl)
        request.allowsConstrainedNetworkAccess = false
        return Publishers.Publish(onOutputFrom: trigger.signal(activatedBy: TriggerId.load)) {
            kSession.dataTaskPublisher(for: request)
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
                .catch { _ in
                    Empty()
                }
        }
        .prepend(self)
        .eraseToAnyPublisher()
    }

    func imageSourcePublisher() -> AnyPublisher<ImageSource, Never> {
        Empty().eraseToAnyPublisher()
    }
}
