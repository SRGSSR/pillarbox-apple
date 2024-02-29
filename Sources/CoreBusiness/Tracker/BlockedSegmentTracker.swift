//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

class BlockedSegmentTracker: PlayerItemTracker {
    required init(configuration: Void) {}
    func enable(for player: Player) {}
    func updateMetadata(with metadata: MediaComposition) {}
    func updateProperties(with properties: PlayerProperties) {}
    func disable() {}
}
