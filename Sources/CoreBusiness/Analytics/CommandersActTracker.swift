//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player

/// Stream tracker for Commanders Act.
public final class CommandersActTracker: PlayerItemTracker {
    private let id = UUID()

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    public func enable(for player: Player) {
        print("--> enable Commanders Act \(id)")
    }

    public func disable() {
        print("--> disable Commanders Act \(id)")
    }
}
