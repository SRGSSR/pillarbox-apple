//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore

protocol ItemLoading {
    var content: ItemContent { get }
    var contentPublisher: AnyPublisher<ItemContent, Never> { get }

    func enableTrackers(for player: Player)
    func disableTrackers()
}

private enum TriggerId: Hashable {
    case load(UUID)
    case reset(UUID)
}

// TODO: Where should we put the reload mechanism?
private let kTrigger = Trigger()

func loadItem(for id: UUID) {
    kTrigger.activate(for: TriggerId.load(id))
}

func reloadItem(for id: UUID) {
    kTrigger.activate(for: TriggerId.reset(id))
    kTrigger.activate(for: TriggerId.load(id))
}

final class ItemLoader<M>: ItemLoading {
    private let id = UUID()
    private let trackerAdapters: [TrackerAdapter<M>]

    @Published private(set) var content: ItemContent

    init<P>(
        publisher: P,
        metadataAdapter: MetadataAdapter<M>,
        trackerAdapters: [TrackerAdapter<M>]
    ) where P: Publisher, P.Output == Asset<M> {
        content = .init(id: id, resource: .loading, metadata: .empty)

        // TODO: Is there now a way to avoid associating this id?
        self.trackerAdapters = trackerAdapters.map { [id] adapter in
            adapter.withId(id)
        }

        Publishers.PublishAndRepeat(onOutputFrom: kTrigger.signal(activatedBy: TriggerId.reset(id))) { [id] in
            publisher
                .map { asset in
                    ItemContent(
                        id: id,
                        resource: asset.resource,
                        metadata: metadataAdapter.metadata(from: asset.metadata)
                    )
                }
                .catch { error in
                    Just(ItemContent(id: id, resource: .failing(error: error), metadata: .empty))
                }
        }
        .wait(untilOutputFrom: kTrigger.signal(activatedBy: TriggerId.load(id)))
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
