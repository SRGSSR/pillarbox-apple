//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Charts
import PillarboxPlayer
import SwiftUI

struct MetricsView: View {
    let player: Player

    @StateObject private var metricsCollector = MetricsCollector(interval: .init(value: 1, timescale: 1))

    private var metrics: [Metrics] {
        metricsCollector.metrics
    }

    var body: some View {
        VStack {
            IndicatedBitrateChart(metrics: metrics)
            ObservedBitrateChart(metrics: metrics)
            MediaRequestChart(metrics: metrics)
        }
        .bind(metricsCollector, to: player)
    }
}

#Preview {
    MetricsView(player: .init(item: .urn("urn:rts:video:14968211")))
}
