//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player

/// Tracker for comScore stream tracking.
public final class ComScoreTracker: PlayerItemTracker {
    private let id = UUID()

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    public func enable(for player: Player) {
        print("--> enable comScore \(id)")
    }

    public func disable() {
        print("--> disable comScore \(id)")
    }
}
