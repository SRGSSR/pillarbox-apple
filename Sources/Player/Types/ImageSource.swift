//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore

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
    public static func image(_ data: Data) -> Self {
        Self(kind: .image(data))
    }

    // swiftlint:disable:next missing_docs
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.kind == rhs.kind
    }
}

public extension ImageSource {
    /// The image URL, if any.
    var url: URL? {
        switch kind {
        case let .url(standardResolution: standardResolutionUrl, lowResolution: _):
            return standardResolutionUrl
        default:
            return nil
        }
    }

    /// The image data, if any.
    var data: Data? {
        switch kind {
        case let .image(data):
            return data
        default:
            return nil
        }
    }
}

extension ImageSource {
    @discardableResult
    func fetchData() -> Data? {
        switch kind {
        case let .image(data):
            return data
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
                .map { .image($0.data) }
                .catch { _ in Empty() }
        }
        .prepend(self)
        .eraseToAnyPublisher()
    }

    func imageSourcePublisher() -> AnyPublisher<ImageSource, Never> {
        guard case let .url(standardResolution: standardResolutionUrl, lowResolution: _) = kind else {
            return Just(self).eraseToAnyPublisher()
        }
        return kSession.dataTaskPublisher(for: standardResolutionUrl)
            .map { .image($0.data) }
            .replaceError(with: self)
            .eraseToAnyPublisher()
    }
}
