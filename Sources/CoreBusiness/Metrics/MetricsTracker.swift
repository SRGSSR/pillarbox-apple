//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

public final class MetricsTracker: PlayerItemTracker {
    public init(configuration: Void) {}

    public func enable(for player: Player) {}

    public func updateMetadata(with metadata: Void) {}

    public func updateProperties(with properties: PlayerProperties) {}

    public func receiveMetricEvent(_ event: MetricEvent) {}

    public func disable() {}
}
