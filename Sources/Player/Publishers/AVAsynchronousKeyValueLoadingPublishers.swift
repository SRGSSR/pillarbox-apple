//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVAsynchronousKeyValueLoading {
    /// A publisher emitting values for a given asynchronously loaded property.
    func propertyPublisher<T>(_ property: AVAsyncProperty<Self, T>) -> AnyPublisher<T, Error> {
        AsyncPublisher {
            try await self.load(property)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>
    ) -> AnyPublisher<(A, B), Error> {
        AsyncPublisher {
            try await self.load(propertyA, propertyB)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B, C>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>,
        _ propertyC: AVAsyncProperty<Self, C>
    ) -> AnyPublisher<(A, B, C), Error> {
        // swiftlint:disable:previous large_tuple
        AsyncPublisher {
            try await self.load(propertyA, propertyB, propertyC)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B, C, D>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>,
        _ propertyC: AVAsyncProperty<Self, C>,
        _ propertyD: AVAsyncProperty<Self, D>
    ) -> AnyPublisher<(A, B, C, D), Error> {
        // swiftlint:disable:previous large_tuple
        AsyncPublisher {
            try await self.load(propertyA, propertyB, propertyC, propertyD)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B, C, D, E>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>,
        _ propertyC: AVAsyncProperty<Self, C>,
        _ propertyD: AVAsyncProperty<Self, D>,
        _ propertyE: AVAsyncProperty<Self, E>
    ) -> AnyPublisher<(A, B, C, D, E), Error> {
        // swiftlint:disable:previous large_tuple
        AsyncPublisher {
            try await self.load(propertyA, propertyB, propertyC, propertyD, propertyE)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B, C, D, E, F>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>,
        _ propertyC: AVAsyncProperty<Self, C>,
        _ propertyD: AVAsyncProperty<Self, D>,
        _ propertyE: AVAsyncProperty<Self, E>,
        _ propertyF: AVAsyncProperty<Self, F>
    ) -> AnyPublisher<(A, B, C, D, E, F), Error> {
        // swiftlint:disable:previous large_tuple
        AsyncPublisher {
            try await self.load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B, C, D, E, F, G>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>,
        _ propertyC: AVAsyncProperty<Self, C>,
        _ propertyD: AVAsyncProperty<Self, D>,
        _ propertyE: AVAsyncProperty<Self, E>,
        _ propertyF: AVAsyncProperty<Self, F>,
        _ propertyG: AVAsyncProperty<Self, G>
    ) -> AnyPublisher<(A, B, C, D, E, F, G), Error> {
        // swiftlint:disable:previous large_tuple
        AsyncPublisher {
            try await self.load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG)
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asynchronously loaded properties.
    func propertyPublisher<A, B, C, D, E, F, G, H>(
        _ propertyA: AVAsyncProperty<Self, A>,
        _ propertyB: AVAsyncProperty<Self, B>,
        _ propertyC: AVAsyncProperty<Self, C>,
        _ propertyD: AVAsyncProperty<Self, D>,
        _ propertyE: AVAsyncProperty<Self, E>,
        _ propertyF: AVAsyncProperty<Self, F>,
        _ propertyG: AVAsyncProperty<Self, G>,
        _ propertyH: AVAsyncProperty<Self, H>
    ) -> AnyPublisher<(A, B, C, D, E, F, G, H), Error> {
        // swiftlint:disable:previous large_tuple
        AsyncPublisher {
            try await self.load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG, propertyH)
        }
        .eraseToAnyPublisher()
    }
}
