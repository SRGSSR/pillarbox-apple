//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore
import PillarboxPlayer

enum AssetLoaderMock: AssetLoader {
    struct Input {
        enum Mode {
            case playable(URL)
            case updated(URL, metadata: PlayerMetadata, interval: TimeInterval)
            case failing(Error)
            case unavailable(Error)
        }

        let mode: Mode
        let metadata: PlayerMetadata
        let delay: TimeInterval

        var id: String {
            switch mode {
            case let .playable(url), let .updated(url, metadata: _, interval: _):
                return url.absoluteString
            case let .failing(error), let .unavailable(error):
                return error.localizedDescription
            }
        }

        static func playable(url: URL, metadata: PlayerMetadata = .empty, after delay: TimeInterval = 0) -> Self {
            .init(mode: .playable(url), metadata: metadata, delay: delay)
        }

        static func playable(
            url: URL,
            metadata: PlayerMetadata = .empty,
            after delay: TimeInterval = 0,
            updatedWithMetadata updatedMetadata: PlayerMetadata = .empty,
            interval: TimeInterval = 0
        ) -> Self {
            .init(mode: .updated(url, metadata: updatedMetadata, interval: interval), metadata: metadata, delay: delay)
        }

        static func failing(with error: Error, after delay: TimeInterval = 0) -> Self {
            .init(mode: .failing(error), metadata: .empty, delay: delay)
        }

        static func unavailable(with error: Error, after delay: TimeInterval = 0) -> Self {
            .init(mode: .failing(error), metadata: .empty, delay: delay)
        }
    }

    static func metadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        directMetadataPublisher(for: input)
            .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
    }

    static func directMetadataPublisher(for input: Input) -> AnyPublisher<PlayerMetadata, any Error> {
        switch input.mode {
        case .playable, .unavailable:
            return Just(input.metadata)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case let .updated(_, metadata: metadata, interval: delay):
            return Just(metadata)
                .delayIfNeeded(for: .seconds(delay), scheduler: DispatchQueue.main)
                .prepend(input.metadata)
                .delayIfNeeded(for: .seconds(input.delay), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case let .failing(error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    static func asset(from input: Input, metadata: PlayerMetadata) -> Asset {
        switch input.mode {
        case let .playable(url), let .updated(url, metadata: _, interval: _):
            return .simple(url: url)
        case let .failing(error), let .unavailable(error):
            return .unavailable(with: error)
        }
    }

    static func playerMetadata(from input: Input, metadata: PlayerMetadata?) -> PlayerMetadata {
        metadata ?? .empty
    }
}
