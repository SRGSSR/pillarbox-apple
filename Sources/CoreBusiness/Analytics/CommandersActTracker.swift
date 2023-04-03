//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player

/// Stream tracker for CommandersAct.
public final class CommandersActTracker: PlayerItemTracker {
    private let id = UUID()

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    public func enable(for player: Player) {
        print("--> enable CommandersAct \(id)")
    }

    public func disable() {
        print("--> disable CommandersAct \(id)")
    }
}
