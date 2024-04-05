//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVAsset {
    /// A publisher emitting values for a given asset property.
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

    /// A publisher emitting values for given asset properties.
    func propertyPublisher<A, B>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>
    ) -> AnyPublisher<(A, B), Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.load(propertyA, propertyB)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asset properties.
    func propertyPublisher<A, B, C>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>
    ) -> AnyPublisher<(A, B, C), Error> {
        // swiftlint:disable:previous large_tuple
        Future { promise in
            Task {
                do {
                    let result = try await self.load(propertyA, propertyB, propertyC)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asset properties.
    func propertyPublisher<A, B, C, D>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>
    ) -> AnyPublisher<(A, B, C, D), Error> {
        // swiftlint:disable:previous large_tuple
        Future { promise in
            Task {
                do {
                    let result = try await self.load(propertyA, propertyB, propertyC, propertyD)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asset properties.
    func propertyPublisher<A, B, C, D, E>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>
    ) -> AnyPublisher<(A, B, C, D, E), Error> {
        // swiftlint:disable:previous large_tuple
        Future { promise in
            Task {
                do {
                    let result = try await self.load(propertyA, propertyB, propertyC, propertyD, propertyE)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asset properties.
    func propertyPublisher<A, B, C, D, E, F>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>,
        _ propertyF: AVAsyncProperty<AVAsset, F>
    ) -> AnyPublisher<(A, B, C, D, E, F), Error> {
        // swiftlint:disable:previous large_tuple
        Future { promise in
            Task {
                do {
                    let result = try await self.load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asset properties.
    func propertyPublisher<A, B, C, D, E, F, G>(
        _ propertyA: AVAsyncProperty<AVAsset, A>,
        _ propertyB: AVAsyncProperty<AVAsset, B>,
        _ propertyC: AVAsyncProperty<AVAsset, C>,
        _ propertyD: AVAsyncProperty<AVAsset, D>,
        _ propertyE: AVAsyncProperty<AVAsset, E>,
        _ propertyF: AVAsyncProperty<AVAsset, F>,
        _ propertyG: AVAsyncProperty<AVAsset, G>
    ) -> AnyPublisher<(A, B, C, D, E, F, G), Error> {
        // swiftlint:disable:previous large_tuple
        Future { promise in
            Task {
                do {
                    let result = try await self.load(
                        propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG
                    )
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// A publisher emitting values for given asset properties.
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
        // swiftlint:disable:previous large_tuple
        Future { promise in
            Task {
                do {
                    let result = try await self.load(
                        propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG, propertyH
                    )
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension AVAsset {
    /// A publisher emitting media selection groups as a single value and completing.
    func mediaSelectionGroupsPublisher() -> AnyPublisher<[AVMediaCharacteristic: AVMediaSelectionGroup], Never> {
        propertyPublisher(.availableMediaCharacteristicsWithMediaSelectionOptions)
            .replaceError(with: [])
            .weakCapture(self)
            .map { characteristics, asset in
                Publishers.MergeMany(characteristics.compactMap { characteristic in
                    asset.mediaSelectionGroupPublisher(for: characteristic)
                        .compactMap { $0 }
                        .map { [characteristic: $0] }
                        .replaceError(with: [:])
                })
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            // swiftlint:disable:next reduce_into
            .reduce([:]) { $0.merging($1) { _, new in new } }
            .eraseToAnyPublisher()
    }

    private func mediaSelectionGroupPublisher(for characteristic: AVMediaCharacteristic) -> AnyPublisher<AVMediaSelectionGroup?, Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.loadMediaSelectionGroup(for: characteristic)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension AVAsset {
    func chaptersPublisher(bestMatchingPreferredLanguages preferredLanguages: [String]) -> AnyPublisher<[AVTimedMetadataGroup], Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.loadChapterMetadataGroups(bestMatchingPreferredLanguages: preferredLanguages)
                    promise(.success(result))
                }
                catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
