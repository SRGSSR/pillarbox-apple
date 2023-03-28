//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import OSLog
import Player

final class DemoTracker: PlayerItemTracker {
    struct Metadata {
        let title: String
    }

    private static let logger = Logger(category: "DemoTracker")
    private var cancellables = Set<AnyCancellable>()
    private let id = UUID()

    init(configuration: Void, metadataPublisher: AnyPublisher<Metadata, Never>) {
        Self.logger.debug("Init demo tracker \(self.id)")

        metadataPublisher.sink { [id] metadata in
            Self.logger.debug("Update demo tracker metadata for \(id): \(metadata.title)")
        }
        .store(in: &cancellables)
    }

    func enable(for player: Player) {
        Self.logger.debug("Enable demo tracker for \(self.id)")
    }

    func disable() {
        Self.logger.debug("Disable demo tracker for \(self.id)")
    }

    deinit {
        Self.logger.debug("Deinit demo tracker \(self.id)")
    }
}
