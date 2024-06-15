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
        Group {
            if !metrics.isEmpty {
                VStack {
                    IndicatedBitrateChart(metrics: metrics)
                    ObservedBitrateChart(metrics: metrics)
                    MediaRequestChart(metrics: metrics)
                }
            }
            else {
                Text("No metrics")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .bind(metricsCollector, to: player)
    }
}
