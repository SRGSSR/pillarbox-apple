//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVAsset {
    /// A publisher emitting media selection groups as a single value and completing.
    func mediaSelectionGroupsPublisher() -> AnyPublisher<[AVMediaCharacteristic: AVMediaSelectionGroup], Never> {
        propertyPublisher(.availableMediaCharacteristicsWithMediaSelectionOptions)
            .replaceError(with: [])
            .weakCapture(self)
            .map { characteristics, asset in
                Publishers.MergeMany(characteristics.compactMap { characteristic in
                    asset.mediaSelectionGroupPublisher(for: characteristic)
                        .compactMap(\.self)
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
