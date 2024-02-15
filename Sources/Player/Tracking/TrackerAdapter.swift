//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

/// An adapter which instantiates and manages a tracker of a specified type.
///
/// An adapter transforms metadata delivered by a player item into the metadata format required by the tracker.
public class TrackerAdapter<M: AssetMetadata> {
    private let tracker: any PlayerItemTracker
    private let update: (M) -> Void
    private var cancellables = Set<AnyCancellable>()
    private var id = UUID()

    /// Creates an adapter for a type of tracker with the provided mapping to its metadata format.
    /// 
    /// - Parameters:
    ///   - trackerType: The type of the tracker to instantiate and manage.
    ///   - configuration: The tracker configuration.
    ///   - mapper: The metadata mapper.
    public init<T>(trackerType: T.Type, configuration: T.Configuration, mapper: ((M) -> T.Metadata)?) where T: PlayerItemTracker {
        let tracker = trackerType.init(configuration: configuration)
        update = { metadata in
            if let mapper {
                tracker.updateMetadata(with: mapper(metadata))
            }
        }
        self.tracker = tracker
    }

    func withId(_ id: UUID) -> Self {
        self.id = id
        return self
    }

    func enable(for player: Player) {
        tracker.enable(for: player)

        player.propertiesPublisher
            .sink { [weak self] properties in
                guard let self, properties.id == id else { return }
                tracker.updateProperties(with: properties)
            }
            .store(in: &cancellables)
    }

    func update(metadata: M) {
        update(metadata)
    }

    func disable() {
        cancellables = []
        tracker.disable()
    }
}
