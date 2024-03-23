//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore

final class ItemLoader<M>: ItemLoading {
    private let id = UUID()
    private let trackerAdapters: [TrackerAdapter<M>]

    @Published private(set) var content: ItemContent

    init<P>(
        publisher: P,
        metadataAdapter: MetadataAdapter<M>,
        trackerAdapters: [TrackerAdapter<M>]
    ) where P: Publisher, P.Output == Asset<M> {
        content = .init(id: id, resource: .loading)

        // TODO: Is there now a way to avoid associating this id?
        self.trackerAdapters = trackerAdapters.map { [id] adapter in
            adapter.withId(id)
        }

        Publishers.PublishAndRepeat(onOutputFrom: ItemOrchestrator.resetSignal(for: id)) { [id] in
            publisher
                .map { asset in
                    ItemContent(
                        id: id,
                        resource: asset.resource,
                        metadata: metadataAdapter.metadata(from: asset.metadata),
                        configuration: asset.configuration
                    )
                }
                .catch { error in
                    Just(ItemContent(id: id, resource: .failing(error: error)))
                }
        }
        .wait(untilOutputFrom: ItemOrchestrator.loadSignal(for: id))
        .receive(on: DispatchQueue.main)
        .assign(to: &$content)
    }

    var contentPublisher: AnyPublisher<ItemContent, Never> {
        $content.eraseToAnyPublisher()
    }

    func enableTrackers(for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func disableTrackers() {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }
}
