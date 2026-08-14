//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVAsset {
    func mediaSelectionProviderPublisher() -> AnyPublisher<MediaSelectionProvider, Never> {
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
            .map(MediaSelectionProvider.init)
            .eraseToAnyPublisher()
    }

    func mediaSelectionConfiguratorPublisher() -> AnyPublisher<MediaSelectionConfigurator?, Never> {
        Publishers.CombineLatest(
            preferredMediaSelectionPublisher(),
            mediaSelectionProviderPublisher()
        )
        .map { selection, provider in
            guard let selection else { return nil }
            return MediaSelectionConfigurator(selection: selection, provider: provider)
        }
        .eraseToAnyPublisher()
    }

    private func preferredMediaSelectionPublisher() -> AnyPublisher<AVMediaSelection?, Never> {
        propertyPublisher(.preferredMediaSelection)
            .map(\.self)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private func mediaSelectionGroupPublisher(for characteristic: AVMediaCharacteristic) -> AnyPublisher<AVMediaSelectionGroup?, Error> {
        AsyncPublisher {
            try await self.loadMediaSelectionGroup(for: characteristic)
        }
        .eraseToAnyPublisher()
    }
}
