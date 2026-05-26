//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

struct AssetLoaderMockInput {
    enum Mode {
        case playable(URL)
        case updatable(URL, after: TimeInterval, with: PlayerMetadata)
        case failing(Error)
        case unavailable(Error)
    }

    private let mode: Mode
    private let metadata: PlayerMetadata
    private let delay: TimeInterval

    var id: String {
        switch mode {
        case let .playable(url), let .updatable(url, _, _):
            return url.absoluteString
        case let .failing(error), let .unavailable(error):
            return error.localizedDescription
        }
    }

    static func playable(url: URL, metadata: PlayerMetadata = .empty, after delay: TimeInterval = 0) -> Self {
        .init(mode: .playable(url), metadata: metadata, delay: delay)
    }

    static func updatable(
        url: URL,
        metadata: PlayerMetadata = .empty,
        to updatedMetadata: PlayerMetadata,
        after interval: TimeInterval = 0
    ) -> Self {
        .init(mode: .updatable(url, after: interval, with: updatedMetadata), metadata: metadata, delay: 0)
    }

    static func failing(with error: Error, after delay: TimeInterval = 0) -> Self {
        .init(mode: .failing(error), metadata: .empty, delay: delay)
    }

    static func unavailable(with error: Error, after delay: TimeInterval = 0) -> Self {
        .init(mode: .failing(error), metadata: .empty, delay: delay)
    }

    func metadataPublisher() -> AnyPublisher<PlayerMetadata, any Error> {
        switch mode {
        case .playable, .unavailable:
            return Just(metadata)
                .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case let .failing(error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        case let .updatable(_, interval, updatedMetadata):
            return Just(updatedMetadata)
                .delayIfNeeded(for: .seconds(interval), scheduler: DispatchQueue.main)
                .prepend(metadata)
                .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func asset() -> Asset {
        switch mode {
        case let .playable(url), let .updatable(url, _, _):
            return .simple(url: url)
        case let .failing(error), let .unavailable(error):
            return .unavailable(with: error)
        }
    }
}
