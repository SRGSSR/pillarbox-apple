//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVAsset {
    func propertyPublisher<T>(_ property: AVAsyncProperty<AVAsset, T>) -> AnyPublisher<T, Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.load(property)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func propertyPublisher<A, B>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>
    ) -> AnyPublisher<(A, B), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func propertyPublisher<A, B, C>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>
    ) -> AnyPublisher<(A, B, C), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func propertyPublisher<A, B, C, D>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>
    ) -> AnyPublisher<(A, B, C, D), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func propertyPublisher<A, B, C, D, E>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>
    ) -> AnyPublisher<(A, B, C, D, E), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func propertyPublisher<A, B, C, D, E, F>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>,
        _ propertyF: AVAsyncProperty<AVAsset, F>
    ) -> AnyPublisher<(A, B, C, D, E, F), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func propertyPublisher<A, B, C, D, E, F, G>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>,
        _ propertyF: AVAsyncProperty<AVAsset, F>,
        _ propertyG: AVAsyncProperty<AVAsset, G>
    ) -> AnyPublisher<(A, B, C, D, E, F, G), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func propertyPublisher<A, B, C, D, E, F, G, H>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>,
        _ propertyF: AVAsyncProperty<AVAsset, F>,
        _ propertyG: AVAsyncProperty<AVAsset, G>,
        _ propertyH: AVAsyncProperty<AVAsset, H>
    ) -> AnyPublisher<(A, B, C, D, E, F, G, H), Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
